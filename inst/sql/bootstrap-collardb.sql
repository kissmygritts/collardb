create table devices (
  id integer primary key autoincrement,
  serial_number text not null,
  purchase_date date,
  frequency text,
  vendor text,
  model text,
  network text
);

create table animals (
  id integer primary key autoincrement,
  animal_id text not null,
  name text,
  species text,
  study text,
  sex text,
  age text
);

create table deployments (
  id integer primary key autoincrement,
  animal_fk integer references animals(id),
  devices_fk integer references devices(id),
  inservice text,
  outservice text
);

create table telemetry (
  id integer primary key autoincrement,
  animal_fk integer references animals(id),
  device_fk integer references devices(id),
  acq_timestamp timestamp,
  x real,
  y real
);
