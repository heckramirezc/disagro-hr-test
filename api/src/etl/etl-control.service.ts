import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { EtlJob } from './entities/etl-job.entity';
import { StartEtlDto } from './dto/start-etl.dto';
import { Cron, CronExpression } from '@nestjs/schedule';

@Injectable()
export class EtlControlService {
  constructor(
    @InjectRepository(EtlJob)
    private etlJobRepository: Repository<EtlJob>,
  ) {}

  async startEtlJob(startEtlDto: StartEtlDto): Promise<EtlJob> {
    const { date, lang } = startEtlDto;
    
    const now = new Date();
    const newJob = this.etlJobRepository.create({
      job_type: 'INGESTA_DIARIA', 
      data_date: date,
      status: 'EN_CURSO', 
      requested_at: now,
      started_at: now,
    });

    const savedJob = await this.etlJobRepository.save(newJob);
    return savedJob;
  }

  async getJobStatus(job_id: string): Promise<EtlJob> {
    const job = await this.etlJobRepository.findOne({ where: { job_id } });

    if (!job) {
      throw new NotFoundException(`Job con ID "${job_id}" no encontrado.`);
    }

    return job;
  }

  // Simulación de estado ETL
  @Cron(CronExpression.EVERY_MINUTE)
  async simulateJobCompletion() {
    const jobToComplete = await this.etlJobRepository.findOne({
      where: { status: 'EN_CURSO' },
      order: { started_at: 'ASC' },
    });

    if (jobToComplete) {
      jobToComplete.status = 'COMPLETADO';
      jobToComplete.finished_at = new Date();
      jobToComplete.rows_processed = Math.floor(Math.random() * (150000 - 50000 + 1)) + 50000;
      jobToComplete.worker_id = 'simulador-local';

      await this.etlJobRepository.save(jobToComplete);
    }
  }
}
