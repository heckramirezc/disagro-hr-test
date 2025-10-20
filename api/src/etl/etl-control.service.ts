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
}
