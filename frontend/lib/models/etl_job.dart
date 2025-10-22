class EtlJob {
  final String jobId;
  final String status;
  final String startTime;
  final String? endTime;

  EtlJob({required this.jobId, required this.status, required this.startTime, this.endTime});

  factory EtlJob.fromJson(Map<String, dynamic> json) => EtlJob(
        jobId: json['jobId'] as String,
        status: json['status'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String?,
      );
}
