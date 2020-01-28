create table devices (
  id text primary key not null,
  serial_number text not null,
  purchase_date date,
  frequency text,
  vendor text,
  model text,
  network text
);

create table animals (
  id text primary key not null,
  animal_id text not null,
  name text,
  species text,
  study text,
  sex text,
  age_class text
);

create table deployments (
  id text primary key not null,
  animal_fk text references animals(id),
  device_fk text references devices(id),
  inservice text,
  outservice text
);

create table telemetry (
  id text primary key not null,
  animal_fk integer references animals(id),
  device_fk integer references devices(id),
  acq_timestamp timestamp,
  x real,
  y real
);
