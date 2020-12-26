% Clean up script for the Lane Following Test Bench Example
%
% This script cleans up the LF example model. It is triggered by the
% CloseFcn callback.
%
%   This is a helper script for example purposes and may be removed or
%   modified in the future.

%   Copyright 2019 The MathWorks, Inc.

clear actor_Profiles
clear assigThresh
clear blk
clear BusActors1
clear BusActors1Actors
clear BusDetectionConcatenation1
clear BusDetectionConcatenation1Detections
clear BusDetectionConcatenation1DetectionsMeasurementParameters
clear BusLaneBoundaries1
clear BusLaneBoundaries1LaneBoundaries
clear BusLanes
clear BusLanesLaneBoundaries
clear BusMultiObjectTracker1
clear BusMultiObjectTracker1Tracks
clear BusRadar
clear BusRadarDetections
clear BusRadarDetectionsMeasurementParameters
clear BusRadarDetectionsObjectAttributes
clear BusVision
clear BusVisionDetections
clear BusVisionDetectionsMeasurementParameters
clear BusVisionDetectionsObjectAttributes
clear Cf
clear clusterSize
clear Cr
clear default_spacing
clear egoCar
clear Iz
clear LaneSensor
clear LaneSensorBoundaries
clear lf
clear lr
clear m
clear M
clear max_ac
clear max_steer
clear min_ac
clear min_steer
clear modelName
clear N
clear numCoasts
clear numSensors
clear numTracks
clear posSelector
clear PredictionHorizon
clear refModel
clear s
clear scenario
clear scenarioId
clear scenariosNames
clear scenarioStopTimes
clear simStopTime
clear tau
clear time_gap
clear Ts
clear v0_ego
clear v_set
clear velSelector
clear wasModelLoaded
clear wasReModelLoaded
clear x0_ego
clear y0_ego
clear yaw0_ego

% If ans was created by the model, clean it too
if exist('ans','var') && ischar(ans) && (strcmpi(ans,'BusMultiObjectTracker1')) %#ok<NOANS>
    clear ans
end