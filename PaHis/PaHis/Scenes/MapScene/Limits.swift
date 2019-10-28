import UIKit

struct Map {
    static let limits = [[-84.480000000000004,-3.38],[-84.460000000000008,-3.34],[-80.280000000000001,-3.34],[-80.180000000000007,-3.4],[-80.140000000000001,-3.76],[-80.100000000000009,-3.8],[-80.079999999999998,-3.92],[-80.100000000000009,-3.96],[-80.219999999999999,-4],[-80.239999999999995,-4.06],[-80.359999999999999,-4.04],[-80.420000000000002,-4.06],[-80.400000000000006,-4.16],[-80.299999999999997,-4.14],[-80.260000000000005,-4.18],[-80.260000000000005,-4.24],[-80.320000000000007,-4.28],[-80.320000000000007,-4.32],[-80.379999999999995,-4.34],[-80.400000000000006,-4.42],[-80.280000000000001,-4.36],[-80.200000000000003,-4.24],[-80.079999999999998,-4.24],[-79.960000000000008,-4.34],[-79.879999999999995,-4.34],[-79.820000000000007,-4.38],[-79.799999999999997,-4.44],[-79.620000000000005,-4.38],[-79.540000000000006,-4.46],[-79.439999999999998,-4.5],[-79.439999999999998,-4.600000000000001],[-79.379999999999995,-4.78],[-79.340000000000003,-4.78],[-79.239999999999995,-4.92],[-79.040000000000006,-4.92],[-79,-4.84],[-78.960000000000008,-4.84],[-78.939999999999998,-4.68],[-78.859999999999999,-4.600000000000001],[-78.739999999999995,-4.58],[-78.680000000000007,-4.48],[-78.700000000000003,-4.3],[-78.620000000000005,-4.16],[-78.620000000000005,-3.98],[-78.540000000000006,-3.9],[-78.519999999999996,-3.8],[-78.460000000000008,-3.78],[-78.480000000000004,-3.68],[-78.439999999999998,-3.64],[-78.439999999999998,-3.52],[-78.400000000000006,-3.48],[-78.379999999999995,-3.32],[-78.200000000000003,-3.32],[-78.159999999999997,-3.28],[-78.140000000000001,-3.18],[-78.060000000000002,-3.16],[-77.980000000000004,-3.02],[-77.840000000000003,-2.94],[-77.019999999999996,-2.68],[-76.560000000000002,-2.48],[-75.980000000000004,-1.98],[-75.600000000000009,-1.5],[-75.439999999999998,-0.92],[-75.359999999999999,-0.88],[-75.280000000000001,-0.94],[-75.320000000000007,-0.82],[-75.320000000000007,-0.64],[-75.280000000000001,-0.58],[-75.439999999999998,-0.46],[-75.519999999999996,-0.34],[-75.540000000000006,-0.24],[-75.659999999999997,-0.22],[-75.659999999999997,-0.08],[-75.5,-0.06],[-75.439999999999998,-0.1],[-75.299999999999997,-0.1],[-75.260000000000005,-0.02],[-75.200000000000003,0.02],[-75.040000000000006,-0.04],[-74.920000000000002,-0.16],[-74.859999999999999,-0.18],[-74.840000000000003,-0.14],[-74.760000000000005,-0.14],[-74.680000000000007,-0.28],[-74.579999999999998,-0.3],[-74.5,-0.38],[-74.5,-0.42],[-74.379999999999995,-0.46],[-74.280000000000001,-0.66],[-74.299999999999997,-0.72],[-74.200000000000003,-0.78],[-74.219999999999999,-0.96],[-74.100000000000009,-1],[-74.060000000000002,-0.96],[-73.980000000000004,-0.96],[-73.960000000000008,-1.04],[-73.859999999999999,-1.08],[-73.799999999999997,-1.2],[-73.780000000000001,-1.16],[-73.700000000000003,-1.16],[-73.700000000000003,-1.2],[-73.579999999999998,-1.22],[-73.400000000000006,-1.56],[-73.460000000000008,-1.68],[-73.340000000000003,-1.74],[-73.180000000000007,-1.7],[-73.159999999999997,-1.76],[-73.120000000000005,-1.76],[-73.100000000000009,-1.82],[-73.060000000000002,-1.84],[-73.079999999999998,-1.98],[-73.019999999999996,-2.06],[-73.019999999999996,-2.12],[-73.120000000000005,-2.22],[-73.060000000000002,-2.28],[-73.040000000000006,-2.26],[-72.939999999999998,-2.28],[-72.900000000000006,-2.32],[-72.900000000000006,-2.38],[-72.840000000000003,-2.38],[-72.820000000000007,-2.34],[-72.680000000000007,-2.34],[-72.620000000000005,-2.3],[-72.460000000000008,-2.38],[-72.379999999999995,-2.36],[-72.359999999999999,-2.42],[-72.280000000000001,-2.38],[-72.219999999999999,-2.4],[-72.120000000000005,-2.36],[-72.100000000000009,-2.3],[-72.060000000000002,-2.28],[-71.980000000000004,-2.32],[-71.960000000000008,-2.26],[-71.900000000000006,-2.24],[-71.879999999999995,-2.16],[-71.799999999999997,-2.14],[-71.780000000000001,-2.1],[-71.680000000000007,-2.1],[-71.680000000000007,-2.14],[-71.600000000000009,-2.18],[-71.439999999999998,-2.22],[-71.359999999999999,-2.32],[-71.299999999999997,-2.28],[-71.200000000000003,-2.3],[-71.159999999999997,-2.24],[-71.060000000000002,-2.22],[-71.040000000000006,-2.16],[-70.960000000000008,-2.16],[-70.840000000000003,-2.18],[-70.799999999999997,-2.24],[-70.640000000000001,-2.3],[-70.600000000000009,-2.36],[-70.439999999999998,-2.4],[-70.400000000000006,-2.46],[-70.400000000000006,-2.44],[-70.260000000000005,-2.46],[-70.180000000000007,-2.58],[-70.060000000000002,-2.6],[-70.019999999999996,-2.64],[-70,-2.76],[-70.040000000000006,-2.84],[-70.640000000000001,-3.78],[-70.560000000000002,-3.76],[-70.5,-3.82],[-70.460000000000008,-3.82],[-70.379999999999995,-3.76],[-70.280000000000001,-3.76],[-69.900000000000006,-4.2],[-69.900000000000006,-4.34],[-70,-4.42],[-70.079999999999998,-4.42],[-70.100000000000009,-4.36],[-70.200000000000003,-4.42],[-70.280000000000001,-4.34],[-70.320000000000007,-4.34],[-70.379999999999995,-4.2],[-70.5,-4.26],[-70.700000000000003,-4.26],[-70.760000000000005,-4.22],[-70.799999999999997,-4.32],[-70.920000000000002,-4.44],[-70.960000000000008,-4.42],[-71.040000000000006,-4.46],[-71.079999999999998,-4.44],[-71.180000000000007,-4.48],[-71.219999999999999,-4.46],[-71.299999999999997,-4.52],[-71.379999999999995,-4.48],[-71.400000000000006,-4.52],[-71.540000000000006,-4.54],[-71.579999999999998,-4.58],[-71.739999999999995,-4.54],[-71.840000000000003,-4.56],[-71.900000000000006,-4.600000000000001],[-71.920000000000002,-4.66],[-72.060000000000002,-4.72],[-72.100000000000009,-4.78],[-72.340000000000003,-4.86],[-72.340000000000003,-4.9],[-72.400000000000006,-4.96],[-72.519999999999996,-5],[-72.620000000000005,-5.12],[-72.780000000000001,-5.16],[-72.820000000000007,-5.2],[-72.840000000000003,-5.38],[-72.900000000000006,-5.46],[-72.879999999999995,-5.54],[-72.920000000000002,-5.62],[-72.900000000000006,-5.66],[-72.939999999999998,-5.74],[-73,-5.78],[-73,-5.82],[-73.120000000000005,-5.92],[-73.140000000000001,-6.04],[-73.180000000000007,-6.06],[-73.200000000000003,-6.12],[-73.060000000000002,-6.38],[-73.060000000000002,-6.48],[-73.100000000000009,-6.56],[-73.159999999999997,-6.58],[-73.200000000000003,-6.640000000000001],[-73.320000000000007,-6.640000000000001],[-73.379999999999995,-6.7],[-73.5,-6.72],[-73.519999999999996,-6.76],[-73.600000000000009,-6.78],[-73.600000000000009,-6.82],[-73.680000000000007,-6.88],[-73.700000000000003,-7.06],[-73.739999999999995,-7.12],[-73.659999999999997,-7.22],[-73.640000000000001,-7.32],[-73.719999999999999,-7.4],[-73.820000000000007,-7.4],[-73.859999999999999,-7.44],[-73.879999999999995,-7.56],[-73.840000000000003,-7.58],[-73.840000000000003,-7.62],[-73.799999999999997,-7.62],[-73.780000000000001,-7.68],[-73.719999999999999,-7.68],[-73.640000000000001,-7.74],[-73.620000000000005,-7.86],[-73.680000000000007,-7.92],[-73.600000000000009,-7.96],[-73.560000000000002,-8.02],[-73.540000000000006,-8.18],[-73.480000000000004,-8.24],[-73.480000000000004,-8.34],[-73.280000000000001,-8.460000000000001],[-73.280000000000001,-8.6],[-73.239999999999995,-8.640000000000001],[-73.120000000000005,-8.66],[-73.019999999999996,-8.859999999999999],[-72.980000000000004,-8.859999999999999],[-72.900000000000006,-8.960000000000001],[-72.879999999999995,-9.1],[-72.900000000000006,-9.16],[-72.960000000000008,-9.200000000000001],[-72.960000000000008,-9.26],[-73.060000000000002,-9.300000000000001],[-73.079999999999998,-9.359999999999999],[-72.700000000000003,-9.359999999999999],[-72.5,-9.44],[-72.400000000000006,-9.42],[-72.239999999999995,-9.5],[-72.239999999999995,-9.58],[-72.200000000000003,-9.6],[-72.200000000000003,-9.720000000000001],[-72.100000000000009,-9.779999999999999],[-72.079999999999998,-9.859999999999999],[-72.100000000000009,-9.960000000000001],[-71.5,-9.94],[-71.400000000000006,-9.960000000000001],[-71.379999999999995,-9.92],[-71.239999999999995,-9.92],[-71.159999999999997,-9.800000000000001],[-71.019999999999996,-9.76],[-71,-9.700000000000001],[-70.939999999999998,-9.700000000000001],[-70.900000000000006,-9.620000000000001],[-70.799999999999997,-9.58],[-70.799999999999997,-9.540000000000001],[-70.719999999999999,-9.5],[-70.640000000000001,-9.4],[-70.460000000000008,-9.380000000000001],[-70.439999999999998,-9.4],[-70.460000000000008,-9.540000000000001],[-70.519999999999996,-9.6],[-70.480000000000004,-9.68],[-70.480000000000004,-9.779999999999999],[-70.519999999999996,-9.84],[-70.560000000000002,-9.84],[-70.560000000000002,-10.880000000000001],[-70.480000000000004,-10.9],[-70.400000000000006,-11],[-70.340000000000003,-11.02],[-70.180000000000007,-11],[-70.159999999999997,-10.960000000000001],[-70.019999999999996,-10.92],[-69.980000000000004,-10.880000000000001],[-69.739999999999995,-10.880000000000001],[-69.719999999999999,-10.92],[-69.540000000000006,-10.9],[-68.920000000000002,-11.880000000000001],[-68.600000000000009,-12.48],[-68.600000000000009,-12.56],[-68.680000000000007,-12.640000000000001],[-68.659999999999997,-12.66],[-68.680000000000007,-12.74],[-68.760000000000005,-12.780000000000001],[-68.780000000000001,-12.880000000000001],[-68.820000000000007,-12.9],[-68.799999999999997,-13.32],[-68.859999999999999,-13.540000000000001],[-68.900000000000006,-13.56],[-68.900000000000006,-13.620000000000001],[-68.960000000000008,-13.68],[-68.960000000000008,-13.720000000000001],[-68.859999999999999,-13.800000000000001],[-68.920000000000002,-13.960000000000001],[-68.840000000000003,-14.02],[-68.820000000000007,-14.1],[-68.780000000000001,-14.120000000000001],[-68.780000000000001,-14.24],[-68.820000000000007,-14.280000000000001],[-68.920000000000002,-14.26],[-68.939999999999998,-14.280000000000001],[-68.960000000000008,-14.32],[-68.939999999999998,-14.42],[-69.100000000000009,-14.540000000000001],[-69.100000000000009,-14.620000000000001],[-69.180000000000007,-14.640000000000001],[-69.180000000000007,-14.780000000000001],[-69.299999999999997,-14.82],[-69.280000000000001,-15],[-69.079999999999998,-15.200000000000001],[-69.060000000000002,-15.26],[-69.200000000000003,-15.380000000000001],[-69.200000000000003,-15.5],[-69.260000000000005,-15.52],[-69.340000000000003,-15.620000000000001],[-69.159999999999997,-16.140000000000001],[-68.939999999999998,-16.140000000000001],[-68.739999999999995,-16.34],[-68.780000000000001,-16.399999999999999],[-68.960000000000008,-16.48],[-68.980000000000004,-16.620000000000001],[-68.939999999999998,-16.640000000000001],[-68.960000000000008,-16.699999999999999],[-69.140000000000001,-16.760000000000002],[-69.180000000000007,-16.879999999999999],[-69.320000000000007,-17.02],[-69.320000000000007,-17.100000000000001],[-69.560000000000002,-17.240000000000002],[-69.420000000000002,-17.34],[-69.420000000000002,-17.52],[-69.659999999999997,-17.719999999999999],[-69.680000000000007,-17.699999999999999],[-69.780000000000001,-17.719999999999999],[-69.739999999999995,-17.900000000000002],[-69.700000000000003,-17.920000000000002],[-69.700000000000003,-18],[-69.840000000000003,-18.219999999999999],[-69.960000000000008,-18.32],[-70.060000000000002,-18.32],[-70.200000000000003,-18.379999999999999],[-70.320000000000007,-18.359999999999999],[-70.340000000000003,-18.400000000000002],[-71.760000000000005,-18.400000000000002],[-72.079999999999998,-18.740000000000002],[-72.840000000000003,-19.400000000000002],[-73.680000000000007,-19.98],[-73.680000000000007,-20.219999999999999],[-73.760000000000005,-20.240000000000002],[-74.280000000000001,-19.699999999999999],[-74.480000000000004,-19.600000000000001],[-74.739999999999995,-19.52],[-74.780000000000001,-19.48],[-75.140000000000001,-19.359999999999999],[-75.540000000000006,-19.16],[-76.019999999999996,-18.84],[-77.140000000000001,-18.219999999999999],[-77.659999999999997,-17.800000000000001],[-78.019999999999996,-17.400000000000002],[-78.620000000000005,-16.84],[-78.900000000000006,-16.440000000000001],[-79.200000000000003,-16.080000000000002],[-79.340000000000003,-15.84],[-79.620000000000005,-15.32],[-79.780000000000001,-14.92],[-79.840000000000003,-14.640000000000001],[-80.019999999999996,-14.52],[-80.400000000000006,-14.120000000000001],[-80.680000000000007,-13.74],[-80.840000000000003,-13.460000000000001],[-81.079999999999998,-12.800000000000001],[-81.239999999999995,-12.02],[-81.280000000000001,-11.56],[-81.5,-10.98],[-82,-10.1],[-82.560000000000002,-9.800000000000001],[-82.960000000000008,-9.5],[-83.5,-8.9],[-83.799999999999997,-8.359999999999999],[-84,-7.8],[-84.180000000000007,-7.48],[-84.359999999999999,-7.04],[-84.5,-6.4],[-84.540000000000006,-5.72],[-84.640000000000001,-5.3],[-84.680000000000007,-4.98],[-84.680000000000007,-4.36],[-84.600000000000009,-3.8],[-84.480000000000004,-3.38]]
}
