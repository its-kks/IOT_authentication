startTime = datetime(2024,2,18,11,23,0);
stopTime = startTime + hours(0.5);
sampleTime = 60; %sample time is in seconds

sc = satelliteScenario(startTime,stopTime,sampleTime);

sat = walkerDelta(sc,2000000,45,280,10,1);

satelliteScenarioViewer(sc, ShowDetails=false);

N = length(sat);
TLE = cell(N,1);
for j=1:N
     TLE{j} = sc.Satellites(j).orbitalElements;
end

TLE_struct = cellfun(@(x) x, TLE);
TLE_table = struct2table(TLE_struct);

% Display the table
disp(TLE_table);

play(sc);