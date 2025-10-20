import { Controller, Get, Post, Param, Body, HttpStatus } from '@nestjs/common';
import { EtlControlService } from './etl-control.service';
import { StartEtlDto } from './dto/start-etl.dto';
import { EtlJob } from './entities/etl-job.entity';
import { ApiTags, ApiOperation, ApiResponse, ApiBody, ApiParam } from '@nestjs/swagger';

@ApiTags('Control del ETL')
@Controller('api/etl')
export class EtlControlController {
  constructor(private readonly etlControlService: EtlControlService) {}

  @Post('start')
  @ApiOperation({ summary: 'Iniciar un nuevo trabajo de ingesta ETL.' })
  @ApiBody({ type: StartEtlDto, description: 'Parámetros del trabajo ETL a iniciar.' })
  @ApiResponse({ 
    status: HttpStatus.CREATED, 
    description: 'Trabajo ETL registrado e iniciado (simulado) con éxito.', 
    type: EtlJob 
  })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Parámetros de entrada inválidos.' })
  async startEtl(@Body() startEtlDto: StartEtlDto): Promise<EtlJob> {
    // TODO: Lógica de invocación real (Cloud Pub/Sub, Cloud Tasks).
    return this.etlControlService.startEtlJob(startEtlDto);
  }
}
