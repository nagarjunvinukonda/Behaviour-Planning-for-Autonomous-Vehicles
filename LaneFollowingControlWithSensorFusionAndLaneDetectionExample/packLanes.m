% extract ego and next left lanes and pack them with BusLaneSensor
function [EgoLane,NextLane] = packLanes(laneDets)

numLanes = laneDets.NumLaneBoundaries;
lanes = laneDets.LaneBoundaries;

% read lateral offset for all lanes
offset = zeros(numLanes,1);
for i = 1:numLanes
    offset(i) = lanes(i).LateralOffset;
end

% create dummy lane with zero strength
dummyLane = struct(...
    'Curvature',single(0),...
    'CurvatureDerivative', single(0), ...
    'HeadingAngle', single(0), ...
    'LateralOffset', single(0), ...
    'Strength', single(0));

% sort the lateral offset
rb = sort(offset(offset<=0),'descend');  % right lanes 
lb = sort(offset(offset>0),'ascend');    % left lane

if length(lb)>=2 % both left ego and next lanes exist?
    egoLeftIndx = searchIndx(offset, numLanes, lb(1)); % index for ego left lane
    EgoLane.Left = getLaneParameters(lanes(egoLeftIndx));

    nextLeftIndx = searchIndx(offset, numLanes, lb(2)); % index for left next lane  
    NextLane.Left = getLaneParameters(lanes(nextLeftIndx));
elseif length(lb)==1 % no left next lane, only left ego lane?
    egoLeftIndx = searchIndx(offset, numLanes, lb(1));  % index for left ego lane 
    EgoLane.Left = getLaneParameters(lanes(egoLeftIndx));
    
    NextLane.Left = dummyLane; % no left next lane
else % no left lanes
    EgoLane.Left = dummyLane;  % no left ego lane
    NextLane.Left = dummyLane; % no left next lane  
end

if length(rb)>=2 % both right ego and next lanes exist?
    egoRightIndx = searchIndx(offset, numLanes, rb(1));  % index for right ego lane   
    EgoLane.Right = getLaneParameters(lanes(egoRightIndx));

    nextRightIndx = searchIndx(offset, numLanes, rb(2)); % index for right next lane      
    NextLane.Right = getLaneParameters(lanes(nextRightIndx));
elseif length(rb)==1 % no right next lane, only right ego lane?
    egoRightIndx = searchIndx(offset, numLanes, rb(1));  % index for right ego lane   
    EgoLane.Right = getLaneParameters(lanes(egoRightIndx));
    
    NextLane.Right = dummyLane; % no right next lane
else % no right lanes
    EgoLane.Right = dummyLane;  % no right ego lane
    NextLane.Right = dummyLane; % no right next lane    
end

end

function indx = searchIndx(offset, num, val)

indx = 0;
for i = 1:num
    if offset(i) == val
        indx = i;
        return;
    end
end

end

% read laneBoundaries and convert units from deg to rad
function laneSensor = getLaneParameters(LaneBoundaries)

laneSensor.Curvature = single(deg2rad(LaneBoundaries.Curvature));
laneSensor.CurvatureDerivative = single(deg2rad(LaneBoundaries.CurvatureDerivative));
laneSensor.HeadingAngle = single(deg2rad(LaneBoundaries.HeadingAngle));
laneSensor.LateralOffset = single(LaneBoundaries.LateralOffset);
laneSensor.Strength = single(LaneBoundaries.Strength);

end