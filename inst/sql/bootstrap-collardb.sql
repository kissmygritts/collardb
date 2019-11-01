create table devices (
  id integer primary key autoincrement,
  serial_number text not null,
  frequency text,
  vendor text,
  network text
);

create table animals (
  id integer primary key autoincrement,
  animal_id text not null,
  species text,
  study text,
  sex text,
  age text
);

create table deployments (
  id integer primary key autoincrement,
  animal_fk integer references animals(id),
  devices_fk integer references devices(id),
  inservice date,
  outservice date
);

create table telemetry (
  id integer primary key autoincrement,
  animal_fk integer references animals(id),
  deployments_fk integer references deployments(id),
  acq_timestamp timestamp,
  x real,
  y real
);
