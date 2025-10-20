import pandas as pd
import numpy as np
import pytest
from datetime import datetime, timedelta
import os
import sys

try:
    from transformation_etl import transform_data, classify_page, normalize_string 
except ImportError:
    current_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.join(current_dir, '..', '..')
    sys.path.insert(0, project_root)
    from etl.transformation_etl import transform_data, classify_page, normalize_string

@pytest.fixture
def sample_data():
    start_date = datetime(2024, 10, 1)    
    df = pd.DataFrame({
        'day': [
            start_date, start_date + timedelta(days=1), start_date + timedelta(days=2), start_date + timedelta(days=3),
            start_date, start_date + timedelta(days=1), start_date + timedelta(days=2), start_date + timedelta(days=3)
        ],
        'language': ['es', 'es', 'es', 'es', 'en', 'en', 'en', 'en'],
        'title': [
            'Python_Prog', 'Python_Prog', 'Python_Prog', 'Python_Prog', 
            'Mi-Canci\xf3n_favorita', 'Mi-Canci\xf3n_favorita', 'Mi-Canci\xf3n_favorita', 'Mi-Canci\xf3n_favorita'
        ],
        'views_total': [100, 150, 110, 220, 50, 75, 75, 90]
    })
    return df

def test_transformation_output_columns(sample_data):
    df_transformed = transform_data(sample_data)
    
    required_cols = [
        'title_normalized', 
        'category', 
        'avg_views_7d', 
        'avg_views_28d', 
        'variations', 
        'trend_score',
        'original_title'
    ]
    
    for col in required_cols:
        assert col in df_transformed.columns, f"Falta la columna requerida: {col}"

def test_title_normalization_and_aggregation(sample_data):
    df_transformed = transform_data(sample_data)
    normalized_titles = df_transformed['title_normalized'].unique().tolist()
    assert 'python_prog' in normalized_titles
    assert 'mi_cancion_favorita' in normalized_titles
    assert len(df_transformed) == 8

def test_page_classification(sample_data):
    df_transformed = transform_data(sample_data)
    python_category = df_transformed[df_transformed['title_normalized'] == 'python_prog']['category'].unique()
    assert list(python_category) == ['Tecnologia']
    cancion_category = df_transformed[df_transformed['title_normalized'] == 'mi_cancion_favorita']['category'].unique()
    assert list(cancion_category) == ['General']
    
def test_variation_calculation(sample_data):
    df_transformed = transform_data(sample_data)
    df_page1 = df_transformed[df_transformed['title_normalized'] == 'python_prog'].sort_values('day')
    expected_variations = [0.0, 50.0, -26.66666667, 100.0]
    np.testing.assert_array_almost_equal(df_page1['variations'].tolist(), expected_variations, decimal=6)

def test_moving_average_calculation(sample_data):    
    df_transformed = transform_data(sample_data)
    df_page1 = df_transformed[df_transformed['title_normalized'] == 'python_prog'].sort_values('day')
    expected_ma_7d = [100.0, 125.0, 120.0, 145.0]
    np.testing.assert_array_almost_equal(df_page1['avg_views_7d'].tolist(), expected_ma_7d, decimal=6)
    
def test_trend_score_with_constant_views():
    df_constant = pd.DataFrame({
        'day': [datetime(2024, 1, 1), datetime(2024, 1, 2), datetime(2024, 1, 3)],
        'language': ['es', 'es', 'es'],
        'title': ['Pagina_Cero', 'Pagina_Cero', 'Pagina_Cero'],
        'views_total': [500, 500, 500] 
    })
    
    df_transformed = transform_data(df_constant)
    assert (df_transformed['trend_score'] == 0.0).all()

def test_trend_score_with_simple_spike():
    df_spike = pd.DataFrame({
        'day': [datetime(2024, 1, 1), datetime(2024, 1, 2), datetime(2024, 1, 3)],
        'language': ['es', 'es', 'es'],
        'title': ['Pagina_Spike', 'Pagina_Spike', 'Pagina_Spike'],
        'views_total': [100, 100, 500] 
    })
    
    df_transformed = transform_data(df_spike).sort_values('day')
    last_trend_score = df_transformed['trend_score'].iloc[-1]
    assert last_trend_score > 1.0 
    np.testing.assert_almost_equal(last_trend_score, 1.154700538, decimal=6)
