import pandas as pd
import unicodedata
import re
import numpy as np

def normalize_string(text):
    if pd.isna(text) or text is None:
        return ""
    
    text_str = str(text).lower()    
    normalized = unicodedata.normalize('NFD', text_str)
    cleaned = ''.join(c for c in normalized if unicodedata.category(c) != 'Mn')
    
    return cleaned

def classify_page(title):
    title_lower = str(title).lower()
    
    if re.search(r'movie|film|actor|series|tv|netflix', title_lower):
        return 'Cine_TV'
    if re.search(r'software|program|ai|data|python|java', title_lower):
        return 'Tecnologia'
    if re.search(r'earthquake|physics|chemistry|space|science|astronomy', title_lower):
        return 'Ciencia'
    if re.search(r'sport|football|soccer|basket|world_cup', title_lower):
        return 'Deportes'
    
    return 'General'


def transform_data(df: pd.DataFrame) -> pd.DataFrame:
    if df.empty:
        print("No hay datos, no se aplicarán transformaciones.")
        return df

    df = df.copy()    
    df_platform_agg = df.groupby(['day', 'language', 'title']).agg(
        views_total=('views_total', 'sum')
    ).reset_index()
    
    df = df_platform_agg.copy()
    df = df.sort_values(by=['language', 'title', 'day'])

    df['category'] = df['title'].apply(classify_page)
    df['original_title'] = df['title'].copy() 

    # Normalización del título para la dimensión dim_page
    df['title_normalized'] = df['title'].apply(normalize_string)    
    df['title_normalized'] = df['title_normalized'].str.replace(r'[_\-\.]', ' ', regex=True) 
    df['title_normalized'] = df['title_normalized'].str.replace(r'[^a-z0-9\s]', '', regex=True)
    df['title_normalized'] = df['title_normalized'].str.replace(r'\s+', '_', regex=True)
    df['title_normalized'] = df['title_normalized'].str.strip('_')
    df['title_normalized'] = df['title_normalized'].str.replace('\x00', '', regex=False).str.strip()
    df['title_normalized'] = df['title_normalized'].apply(lambda x: 'unknown_page' if len(x) == 0 else x) 
    df['title_normalized'] = df['title_normalized'].str.slice(0, 250)
    
    df_final_agg = df.groupby(['day', 'language', 'title_normalized']).agg(
        views_total=('views_total', 'sum'),
        category=('category', 'first'),
        original_title=('original_title', 'first') 
    ).reset_index()
    
    df = df_final_agg.copy()
    df = df.sort_values(by=['language', 'title_normalized', 'day'])
    
    # Cálculo de promedio móvil (7 días)
    df['avg_views_7d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=7, min_periods=1).mean()
    )
    
    # Cálculo de promedio móvil (28 días)
    df['avg_views_28d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).mean()
    )

    # Cálculo de variaciones (Crecimiento porcentual de las vistas de una página)
    df['previous_day_views'] = df.groupby(['language', 'title_normalized'])['views_total'].shift(1)
    df['variations'] = ((df['views_total'] - df['previous_day_views']) / df['previous_day_views']) * 100
    df['variations'] = df['variations'].replace([float('inf'), float('-inf')], 0) 
    df = df.drop(columns=['previous_day_views'])
    df['variations'] = df['variations'].fillna(0)

    # Cálculo de tendencias
    df['rolling_std_28d'] = df.groupby(['language', 'title_normalized'])['views_total'].transform(
        lambda x: x.rolling(window=28, min_periods=1).std()
    )
    
    # Z-score = (valor_actual - media_rolling) / desviacion_estandar_rolling
    std_col = df['rolling_std_28d']
    diff_col = df['views_total'] - df['avg_views_28d']
    
    # Manejo casos donde la desviación estándar es cero
    df['trend_score'] = np.where(
        std_col == 0,
        0, 
        diff_col / std_col
    )
    
    df['trend_score'] = df['trend_score'].fillna(0)

    df = df.drop(columns=['rolling_std_28d'])    
    return df
