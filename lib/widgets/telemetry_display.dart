import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';

class TelemetryDisplay extends StatelessWidget {
  final TelemetryData? telemetry;
  final String? errorMessage;

  const TelemetryDisplay({Key? key, this.telemetry, this.errorMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
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
                                  _buildHeader(),

                                  // Track Data
                                  _buildSectionHeader('Current Track Data'),
                                  _buildTrackData(),

                                  // Car Data
                                  _buildSectionHeader('Current Car Data'),
                                  _buildCarData(),

                                  // Tire Data
                                  _buildSectionHeader('Tyre Data'),
                                  _buildTireData(),

                                  // Gearing and Positioning
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Gearing'),
                                            _buildGearingData(),
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
                                            _buildPositioningData(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  // Velocity and Rotation
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _buildSectionHeader('Velocity (m/s)'),
                                            _buildVelocityData(),
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
                                            _buildRotationData(),
                                          ],
                                        ),
                                      ),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(8),
      color: Colors.blue,
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

  Widget _buildTrackData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 8),
          Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCarData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 8),
          Row(
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

  Widget _buildTireData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          ),
          SizedBox(height: 4),
          Row(
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
          ),
          SizedBox(height: 8),
          Row(
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
          ),
          SizedBox(height: 4),
          Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildGearingData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
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

  Widget _buildPositioningData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
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

  Widget _buildVelocityData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
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

  Widget _buildRotationData() {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
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