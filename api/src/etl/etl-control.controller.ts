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

  @Get('status/:jobId')
  @ApiOperation({ summary: 'Consultar el estado de un trabajo ETL por su ID.' })
  @ApiParam({
    name: 'jobId',
    type: 'string',
    description: 'Identificador único (UUID) del trabajo ETL.',
    example: 'a1b2c3d4-e5f6-7890-1234-567890abcdef',
  })
  @ApiResponse({ status: HttpStatus.OK, description: 'Estado del trabajo ETL encontrado.', type: EtlJob })
  @ApiResponse({ status: HttpStatus.NOT_FOUND, description: 'Job ID no encontrado.' })
  @ApiResponse({ status: HttpStatus.BAD_REQUEST, description: 'Formato de Job ID inválido.' })
  async getEtlJobStatus(@Param('jobId') jobId: string): Promise<EtlJob> {
    const job = await this.etlControlService.getJobStatus(jobId);
    return job;
  }
}
