import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';
import { ApiProperty } from '@nestjs/swagger';

@Entity({ name: 'etl_jobs' })
export class EtlJob {
  @ApiProperty({ description: 'Identificador único del trabajo ETL (UUID).', example: 'a1b2c3d4-e5f6-7890-1234-567890abcdef' })
  @PrimaryColumn({ type: 'uuid', name: 'job_id', default: () => 'gen_random_uuid()' })
  job_id: string;

  @ApiProperty({ description: 'Tipo de trabajo ejecutado (e.g., INGESTA_DIARIA).' })
  @Column({ name: 'job_type', length: 100 })
  job_type: string;

  @ApiProperty({ description: 'Estado actual del trabajo (PENDIENTE, EN_CURSO, COMPLETADO, FALLIDO).' })
  @Column({ length: 50 })
  status: string;

  @ApiProperty({ description: 'Fecha de los datos procesados (YYYY-MM-DD).' })
  @Column({ type: 'date', name: 'data_date' })
  data_date: string;

  @ApiProperty({ description: 'Momento en que se solicitó el inicio del trabajo.' })
  @CreateDateColumn({ type: 'timestamp with time zone', name: 'requested_at' })
  requested_at: Date;

  @ApiProperty({ description: 'Momento en que el worker inició la ejecución.' })
  @Column({ type: 'timestamp with time zone', nullable: true, name: 'started_at' })
  started_at: Date | null;

  @ApiProperty({ description: 'Momento en que el worker finalizó la ejecución.' })
  @Column({ type: 'timestamp with time zone', nullable: true, name: 'finished_at' })
  finished_at: Date | null;

  @ApiProperty({ description: 'Identificador del worker que ejecutó el job.' })
  @Column({ type: 'varchar', nullable: true, name: 'worker_id' })
  worker_id: string | null;

  @ApiProperty({ description: 'Número total de filas procesadas por el ETL.' })
  @Column({ type: 'integer', nullable: true, name: 'rows_processed' })
  rows_processed: number | null;

  @ApiProperty({ description: 'Mensaje de error, si el trabajo falló.' })
  @Column({ type: 'text', nullable: true, name: 'error_message' })
  error_message: string | null;
}
