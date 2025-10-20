import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { EtlJob } from './entities/etl-job.entity';
import { EtlControlService } from './etl-control.service';
import { EtlControlController } from './etl-control.controller';
import { ScheduleModule } from '@nestjs/schedule';

@Module({
  imports: [
    TypeOrmModule.forFeature([EtlJob]),
    ScheduleModule.forRoot(),
  ],
  controllers: [EtlControlController],
  providers: [EtlControlService],
  exports: [EtlControlService],
})
export class EtlControlModule {}
