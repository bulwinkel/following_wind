const Map<String, double> spacings = {
  '0': 0,
  '0.5': 0.5,
  '1': 1,
  '1.5': 1.5,
  '2': 2,
  '2.5': 2.5,
  '3': 3,
  '3.5': 3.5,
  '4': 4,
  '5': 5,
  '6': 6,
  '7': 7,
  '8': 8,
  '9': 9,
  '10': 10,
  '11': 11,
  '12': 12,
  '14': 14,
  '16': 16,
  '20': 20,
  '24': 24,
  '28': 28,
  '32': 32,
  '36': 36,
  '40': 40,
  '44': 44,
  '48': 48,
  '52': 52,
  '56': 56,
  '60': 60,
  '64': 64,
  '72': 72,
  '80': 80,
  '96': 96,
};

// for h- and w- classes
const Map<String, double> fractionalSizes = {
  '1/2': 0.5,
  '1/3': 1 / 3,
  '2/3': 2 / 3,
  '1/4': 1 / 4,
  '2/4': 2 / 4,
  '3/4': 3 / 4,
  '1/5': 1 / 5,
  '2/5': 2 / 5,
  '3/5': 3 / 5,
  '4/5': 4 / 5,
  '1/6': 1 / 6,
  '2/6': 2 / 6,
  '3/6': 3 / 6,
  '4/6': 4 / 6,
  '5/6': 5 / 6,
  '1/12': 1 / 12,
  '2/12': 2 / 12,
  '3/12': 3 / 12,
  '4/12': 4 / 12,
  '5/12': 5 / 12,
  '6/12': 6 / 12,
  '7/12': 7 / 12,
  '8/12': 8 / 12,
  '9/12': 9 / 12,
  '10/12': 10 / 12,
  '11/12': 11 / 12,
};

final List<String> additionalSizes = [
  // Special values
  'auto',
  'full', // 100%
  'screen', // 100vh/vw
  'svh', // Small viewport height
  'lvh', // Large viewport height
  'dvh', // Dynamic viewport height
  'min', // min-content
  'max', // max-content
  'fit', // fit-content

  // Viewport units
  'vh', // viewport height
  'vw', // viewport width
];
