import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';

class TelemetryDisplay extends StatelessWidget {
  final TelemetryData? telemetry;
  final String? errorMessage;

  const TelemetryDisplay({Key? key, this.telemetry, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 600;
    return Container(
      padding: EdgeInsets.all(isDesktop ? 16.0 : 8.0),
      constraints: BoxConstraints(
        maxWidth: isDesktop ? 1200 : double.infinity,
      ),
      child: errorMessage != null
          ? Center(
              child: Text(
                'Error: $errorMessage',
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : telemetry == null
              ? const Center(
                  child: Text(
                    'Waiting for telemetry data...',
                    style: TextStyle(fontSize: 16),
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: IntrinsicWidth(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header
                                  _buildHeader(isDesktop),

                                  // Track Data
                                  _buildSectionHeader('Current Track Data'),
                                  _buildTrackData(context, isDesktop),

                                  // Car Data
                                  _buildSectionHeader('Current Car Data'),
                                  _buildCarData(context, isDesktop),

                                  // Tire Data
                                  _buildSectionHeader('Tyre Data'),
                                  _buildTireData(context, isDesktop),

                                  // Gearing and Positioning
                                  isDesktop ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Gearing'),
                                            _buildGearingData(context, isDesktop),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Positioning (m)'),
                                            _buildPositioningData(isDesktop),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ) : Column(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader('Gearing'),
                                          _buildGearingData(context, isDesktop),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          _buildSectionHeader('Positioning (m)'),
                                          _buildPositioningData(isDesktop),
                                        ],
                                      ),
                                    ],
                                  ),

                                  // Velocity and Rotation
                                  isDesktop ? Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Velocity (m/s)'),
                                            _buildVelocityData(isDesktop),
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 16),
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Rotation'),
                                            _buildRotationData(isDesktop),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ) : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildSectionHeader('Velocity (m/s)'),
                                      _buildVelocityData(isDesktop),
                                      _buildSectionHeader('Rotation'),
                                      _buildRotationData(isDesktop),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildHeader(bool isDesktop) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'GT7 Telemetry Display (Flutter)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Packet ID: ${telemetry?.packetId ?? 0}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      color: Colors.grey[700],
      margin: EdgeInsets.only(top: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTrackData(BuildContext context, bool isDesktop) {
    final isWide = MediaQuery.of(context).size.width > 500;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                    isWide ? Row(
            children: [
              Expanded(
                flex: 2,
                child: Text('Time on track: ${telemetry != null ? (telemetry!.timeOfDay / 1000).toStringAsFixed(0) : '0'}s'),
              ),
              Expanded(
                flex: 1,
                child: Text('Laps: ${telemetry?.currentLap ?? 0}/${telemetry?.totalLaps ?? 0}'),
              ),
              Expanded(
                flex: 1,
                child: Text('Position: ${telemetry?.currentPos ?? 0}/${telemetry?.totalPositions ?? 0}'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Time on track: ${telemetry != null ? (telemetry!.timeOfDay / 1000).toStringAsFixed(0) : '0'}s'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('Laps: ${telemetry?.currentLap ?? 0}/${telemetry?.totalLaps ?? 0}')),
                  Expanded(child: Text('Position: ${telemetry?.currentPos ?? 0}/${telemetry?.totalPositions ?? 0}')),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
                    isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Best Lap Time: ${telemetry != null ? telemetry!.formatLapTime(telemetry!.bestLapTime) : ''}'),
              ),
              Expanded(
                flex: 1,
                child: Text('Current Lap Time: ${telemetry != null ? telemetry!.formatCurLapTime(telemetry!.curLapTime) : ''}'),
              ),
              Expanded(
                flex: 1,
                child: Text('Last Lap Time: ${telemetry != null ? telemetry!.formatLapTime(telemetry!.lastLapTime) : ''}'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Best Lap: ${telemetry != null ? telemetry!.formatLapTime(telemetry!.bestLapTime) : ''}'),
              const SizedBox(height: 4),
              Text('Current Lap: ${telemetry != null ? telemetry!.formatCurLapTime(telemetry!.curLapTime) : ''}'),
              const SizedBox(height: 4),
              Text('Last Lap: ${telemetry != null ? telemetry!.formatLapTime(telemetry!.lastLapTime) : ''}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCarData(BuildContext context, bool isDesktop) {
    final isWide = MediaQuery.of(context).size.width > 650;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Car ID: ${telemetry?.carId ?? 0}'),
              ),
              Expanded(
                flex: 1,
                child: Text('Throttle: ${(telemetry?.throttle ?? 0).toStringAsFixed(1)}%'),
              ),
              Expanded(
                flex: 1,
                child: Text('RPM: ${(telemetry?.rpm ?? 0).toStringAsFixed(0)} rpm'),
              ),
              Expanded(
                flex: 1,
                child: Text('Speed: ${(telemetry?.speed ?? 0).toStringAsFixed(1)} kph'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Car ID: ${telemetry?.carId ?? 0}')),
                  Expanded(child: Text('Throttle: ${(telemetry?.throttle ?? 0).toStringAsFixed(1)}%')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('RPM: ${(telemetry?.rpm ?? 0).toStringAsFixed(0)} rpm')),
                  Expanded(child: Text('Speed: ${(telemetry?.speed ?? 0).toStringAsFixed(1)} kph')),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Brake: ${(telemetry?.brake ?? 0).toStringAsFixed(1)}%'),
              ),
              Expanded(
                flex: 1,
                child: Text('Gear: ${_formatGear(telemetry?.currentGear ?? 0)} (${telemetry?.suggestedGear ?? 0})'),
              ),
              Expanded(
                flex: 1,
                child: Text('Boost: ${(telemetry?.boost ?? 0).toStringAsFixed(2)} kPa'),
              ),
              Expanded(
                flex: 1,
                child: Text('Rev Warning: ${(telemetry?.rpmWarning ?? 0).toStringAsFixed(0)} rpm'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('Brake: ${(telemetry?.brake ?? 0).toStringAsFixed(1)}%')),
                  Expanded(child: Text('Gear: ${_formatGear(telemetry?.currentGear ?? 0)} (${telemetry?.suggestedGear ?? 0})')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('Boost: ${(telemetry?.boost ?? 0).toStringAsFixed(2)} kPa')),
                  Expanded(child: Text('Rev Warning: ${(telemetry?.rpmWarning ?? 0).toStringAsFixed(0)} rpm')),
                ],
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Rev Limiter: ${(telemetry?.rpmLimiter ?? 0).toStringAsFixed(0)} rpm'),
              ),
              Expanded(
                flex: 1,
                child: Text(telemetry?.isEV == true ? 'Charge: ${(telemetry?.fuel ?? 0).toStringAsFixed(0)} kWh' : 'Fuel: ${(telemetry?.fuel ?? 0).toStringAsFixed(0)} lit'),
              ),
              Expanded(
                flex: 1,
                child: Text(telemetry?.isEV == true ? 'Max: ${(telemetry?.maxFuel ?? 0).toStringAsFixed(0)} kWh' : 'Max: ${(telemetry?.maxFuel ?? 0).toStringAsFixed(0)} lit'),
              ),
              Expanded(
                flex: 1,
                child: Text('Est. Speed: ${(telemetry?.estTopSpeed ?? 0).toStringAsFixed(0)} kph'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Clutch: ${(telemetry?.clutch ?? 0).toStringAsFixed(3)}/${(telemetry?.clutchEngaged ?? 0).toStringAsFixed(3)}'),
              ),
              Expanded(
                flex: 1,
                child: Text('RPM After Clutch: ${(telemetry?.rpmAfterClutch ?? 0).toStringAsFixed(0)} rpm'),
              ),
              Expanded(
                flex: 1,
                child: Text('Oil Temp: ${(telemetry?.oilTemp ?? 0).toStringAsFixed(1)} °C'),
              ),
              Expanded(
                flex: 1,
                child: Text('Water Temp: ${(telemetry?.waterTemp ?? 0).toStringAsFixed(1)} °C'),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('Oil Pressure: ${(telemetry?.oilPressure ?? 0).toStringAsFixed(2)} bar'),
              ),
              Expanded(
                flex: 1,
                child: Text('Body/Ride Height: ${(telemetry?.rideHeight ?? 0).toStringAsFixed(0)} mm'),
              ),
              Expanded(
                flex: 2,
                child: Container(), // Empty for layout
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTireData(BuildContext context, bool isDesktop) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('FL: ${(telemetry?.tireTempFL ?? 0).toStringAsFixed(1)} °C'),
              ),
              Expanded(
                flex: 1,
                child: Text('FR: ${(telemetry?.tireTempFR ?? 0).toStringAsFixed(1)} °C'),
              ),
              Expanded(
                flex: 1,
                child: Text('ø: ${(telemetry?.tireDiamFL ?? 0).toStringAsFixed(1)}/${(telemetry?.tireDiamFR ?? 0).toStringAsFixed(1)} cm'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedFL.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSlipRatioFL ?? '0'}'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('FL: ${(telemetry?.tireTempFL ?? 0).toStringAsFixed(1)} °C')),
                  Expanded(child: Text('FR: ${(telemetry?.tireTempFR ?? 0).toStringAsFixed(1)} °C')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('ø: ${(telemetry?.tireDiamFL ?? 0).toStringAsFixed(1)}/${(telemetry?.tireDiamFR ?? 0).toStringAsFixed(1)} cm')),
                  Expanded(child: Text('${telemetry?.tireSpeedFL.toStringAsFixed(1) ?? '0'} kph')),
                ],
              ),
              Text('Slip: ${telemetry?.tireSlipRatioFL ?? '0'}'),
            ],
          ),
          SizedBox(height: 4),
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedFL.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedFR.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSlipRatioFL ?? '0'}/${telemetry?.tireSlipRatioFR ?? '0'}'),
              ),
              Expanded(
                flex: 2,
                child: Container(), // Empty for layout
              ),
            ],
          ) : !isWide ? Row(
            children: [
              Expanded(child: Text('Slip FL/FR: ${telemetry?.tireSlipRatioFL ?? '0'}/${telemetry?.tireSlipRatioFR ?? '0'}')),
            ],
          ) : Container(),
          SizedBox(height: 8),
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('RL: ${(telemetry?.tireTempRL ?? 0).toStringAsFixed(1)} °C'),
              ),
              Expanded(
                flex: 1,
                child: Text('RR: ${(telemetry?.tireTempRR ?? 0).toStringAsFixed(1)} °C'),
              ),
              Expanded(
                flex: 1,
                child: Text('ø: ${(telemetry?.tireDiamRL ?? 0).toStringAsFixed(1)}/${(telemetry?.tireDiamRR ?? 0).toStringAsFixed(1)} cm'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedRL.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSlipRatioRL ?? '0'}'),
              ),
            ],
          ) : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text('RL: ${(telemetry?.tireTempRL ?? 0).toStringAsFixed(1)} °C')),
                  Expanded(child: Text('RR: ${(telemetry?.tireTempRR ?? 0).toStringAsFixed(1)} °C')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text('ø: ${(telemetry?.tireDiamRL ?? 0).toStringAsFixed(1)}/${(telemetry?.tireDiamRR ?? 0).toStringAsFixed(1)} cm')),
                  Expanded(child: Text('${telemetry?.tireSpeedRL.toStringAsFixed(1) ?? '0'} kph')),
                ],
              ),
              Text('Slip: ${telemetry?.tireSlipRatioRL ?? '0'}'),
            ],
          ),
          SizedBox(height: 4),
          isWide ? Row(
            children: [
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedRL.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSpeedRR.toStringAsFixed(1) ?? '0'} kph'),
              ),
              Expanded(
                flex: 1,
                child: Text('${telemetry?.tireSlipRatioRL ?? '0'}/${telemetry?.tireSlipRatioRR ?? '0'}'),
              ),
              Expanded(
                flex: 2,
                child: Container(), // Empty for layout
              ),
            ],
          ) : !isWide ? Row(
            children: [
              Expanded(child: Text('Slip RL/RR: ${telemetry?.tireSlipRatioRL ?? '0'}/${telemetry?.tireSlipRatioRR ?? '0'}')),
            ],
          ) : Container(),
        ],
      ),
    );
  }

  Widget _buildGearingData(BuildContext context, bool isDesktop) {
    final isNarrow = MediaQuery.of(context).size.width < 500;
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: isNarrow ? Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('1: ${(telemetry?.gear1 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('2: ${(telemetry?.gear2 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('3: ${(telemetry?.gear3 ?? 0).toStringAsFixed(3)}')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text('4: ${(telemetry?.gear4 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('5: ${(telemetry?.gear5 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('6: ${(telemetry?.gear6 ?? 0).toStringAsFixed(3)}')),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: Text('7: ${(telemetry?.gear7 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('8: ${(telemetry?.gear8 ?? 0).toStringAsFixed(3)}')),
              Expanded(child: Text('?: ${(telemetry?.gearUnknown ?? 0).toStringAsFixed(3)}')),
            ],
          ),
        ],
      ) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('1st: ${(telemetry?.gear1 ?? 0).toStringAsFixed(3)}'),
          Text('2nd: ${(telemetry?.gear2 ?? 0).toStringAsFixed(3)}'),
          Text('3rd: ${(telemetry?.gear3 ?? 0).toStringAsFixed(3)}'),
          Text('4th: ${(telemetry?.gear4 ?? 0).toStringAsFixed(3)}'),
          Text('5th: ${(telemetry?.gear5 ?? 0).toStringAsFixed(3)}'),
          Text('6th: ${(telemetry?.gear6 ?? 0).toStringAsFixed(3)}'),
          Text('7th: ${(telemetry?.gear7 ?? 0).toStringAsFixed(3)}'),
          Text('8th: ${(telemetry?.gear8 ?? 0).toStringAsFixed(3)}'),
          Text('???: ${(telemetry?.gearUnknown ?? 0).toStringAsFixed(3)}'),
        ],
      ),
    );
  }

  Widget _buildPositioningData(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('X: ${(telemetry?.posX ?? 0).toStringAsFixed(4)}'),
          Text('Y: ${(telemetry?.posY ?? 0).toStringAsFixed(4)}'),
          Text('Z: ${(telemetry?.posZ ?? 0).toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  Widget _buildVelocityData(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('X: ${(telemetry?.velX ?? 0).toStringAsFixed(4)}'),
          Text('Y: ${(telemetry?.velY ?? 0).toStringAsFixed(4)}'),
          Text('Z: ${(telemetry?.velZ ?? 0).toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  Widget _buildRotationData(bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(isDesktop ? 8 : 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('P: ${(telemetry?.rotPitch ?? 0).toStringAsFixed(4)}'),
          Text('Y: ${(telemetry?.rotYaw ?? 0).toStringAsFixed(4)}'),
          Text('R: ${(telemetry?.rotRoll ?? 0).toStringAsFixed(4)}'),
        ],
      ),
    );
  }

  String _formatGear(int gear) {
    if (gear == -1) return 'R'; // Reverse
    return gear.toString();
  }
}