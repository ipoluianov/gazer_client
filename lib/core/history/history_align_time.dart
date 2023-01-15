int alignGroupTimeRange(int groupTimeRange) {
  if (groupTimeRange >= 1 && groupTimeRange < 2) {
    groupTimeRange = 1;
  }

  if (groupTimeRange >= 2 && groupTimeRange < 5) {
    groupTimeRange = 2;
  }

  if (groupTimeRange >= 5 && groupTimeRange < 10) {
    groupTimeRange = 5;
  }

  if (groupTimeRange >= 10 && groupTimeRange < 20) {
    groupTimeRange = 10;
  }

  if (groupTimeRange >= 20 && groupTimeRange < 50) {
    groupTimeRange = 20;
  }

  if (groupTimeRange >= 50 && groupTimeRange < 100) {
    groupTimeRange = 50;
  }

  if (groupTimeRange >= 100 && groupTimeRange < 200) {
    groupTimeRange = 100;
  }

  if (groupTimeRange >= 200 && groupTimeRange < 500) {
    groupTimeRange = 200;
  }

  if (groupTimeRange >= 500 && groupTimeRange < 1000) {
    groupTimeRange = 500;
  }

  if (groupTimeRange >= 1000 && groupTimeRange < 2000) {
    groupTimeRange = 1000;
  }

  if (groupTimeRange >= 2000 && groupTimeRange < 5000) {
    groupTimeRange = 2000;
  }

  if (groupTimeRange >= 5000 && groupTimeRange < 10000) {
    groupTimeRange = 5000;
  }

  if (groupTimeRange >= 10000 && groupTimeRange < 20000) {
    groupTimeRange = 10000;
  }

  if (groupTimeRange >= 20000 && groupTimeRange < 50000) {
    groupTimeRange = 20000;
  }

  if (groupTimeRange >= 50000 && groupTimeRange < 100000) {
    groupTimeRange = 50000;
  }

  if (groupTimeRange >= 100000 && groupTimeRange < 200000) {
    groupTimeRange = 100000; // By 0.2 sec
  }

  if (groupTimeRange >= 200000 && groupTimeRange < 500000) {
    groupTimeRange = 200000; // By 0.2 sec
  }

  if (groupTimeRange >= 500000 && groupTimeRange < 1000000) {
    groupTimeRange = 500000; // By 0.5 sec
  }

  if (groupTimeRange >= 1000000 && groupTimeRange < 5 * 1000000) {
    groupTimeRange = 1000000; // By 1 sec
  }

  if (groupTimeRange >= 5 * 1000000 && groupTimeRange < 15 * 1000000) {
    groupTimeRange = 5 * 1000000; // By 5 sec
  }

  if (groupTimeRange >= 15 * 1000000 && groupTimeRange < 30 * 1000000) {
    groupTimeRange = 15 * 1000000; // By 15 sec
  }

  if (groupTimeRange >= 30 * 1000000 && groupTimeRange < 60 * 1000000) {
    groupTimeRange = 30 * 1000000; // By 30 sec
  }

  if (groupTimeRange >= 60 * 1000000 && groupTimeRange < 2 * 60 * 1000000) {
    groupTimeRange = 60 * 1000000; // By minute
  }

  if (groupTimeRange >= 2 * 60 * 1000000 && groupTimeRange < 3 * 60 * 1000000) {
    groupTimeRange = 2 * 60 * 1000000; // By 2 minute
  }

  if (groupTimeRange >= 3 * 60 * 1000000 && groupTimeRange < 4 * 60 * 1000000) {
    groupTimeRange = 3 * 60 * 1000000; // By 3 minute
  }

  if (groupTimeRange >= 4 * 60 * 1000000 && groupTimeRange < 5 * 60 * 1000000) {
    groupTimeRange = 4 * 60 * 1000000; // By 4 minute
  }

  if (groupTimeRange >= 5 * 60 * 1000000 &&
      groupTimeRange < 10 * 60 * 1000000) {
    groupTimeRange = 5 * 60 * 1000000; // By 5 minute
  }

  if (groupTimeRange >= 10 * 60 * 1000000 &&
      groupTimeRange < 20 * 60 * 1000000) {
    groupTimeRange = 10 * 60 * 1000000; // By 10 minute
  }

  if (groupTimeRange >= 20 * 60 * 1000000 &&
      groupTimeRange < 30 * 60 * 1000000) {
    groupTimeRange = 20 * 60 * 1000000; // By 20 minute
  }

  if (groupTimeRange >= 30 * 60 * 1000000 &&
      groupTimeRange < 60 * 60 * 1000000) {
    groupTimeRange = 30 * 60 * 1000000; // By 30 minute
  }

  if (groupTimeRange >= 60 * 60 * 1000000 &&
      groupTimeRange < 3 * 60 * 60 * 1000000) {
    groupTimeRange = 60 * 60 * 1000000; // By 60 minutes
  }

  if (groupTimeRange >= 3 * 60 * 60 * 1000000 &&
      groupTimeRange < 6 * 60 * 60 * 1000000) {
    groupTimeRange = 3 * 60 * 60 * 1000000; // By 3 Hours
  }

  if (groupTimeRange >= 6 * 60 * 60 * 1000000 &&
      groupTimeRange < 12 * 60 * 60 * 1000000) {
    groupTimeRange = 6 * 60 * 60 * 1000000; // By 6 Hours
  }

  if (groupTimeRange >= 12 * 60 * 60 * 1000000 &&
      groupTimeRange < 24 * 60 * 60 * 1000000) {
    groupTimeRange = 12 * 60 * 60 * 1000000; // By 6 Hours
  }

  if (groupTimeRange >= 24 * 60 * 60 * 1000000) {
    groupTimeRange = 24 * 60 * 60 * 1000000; // By day
  }

  return groupTimeRange;
}
