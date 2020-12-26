classdef (StrictDefaults)helperClusterDetections < matlabshared.tracking.internal.SimulinkBusUtilities ...
        & matlab.system.mixin.CustomIcon
% helperClusterDetections Clusters detections within a small area to a single detection
%
% This is a helper block for example purposes and may be removed or
% modified in the future.
%
% helperClusterDetections clusters all the detections created by a
% single sensor simulation (usually, radarDetectionGenerator) if they
% are within a certain distance, ClusterSize, from each other.
%
% See also: radarDetectionGenerator

% Copyright 2017 The MathWorks, Inc.

%#codegen
    
    properties(Nontunable)
        %ClusterSize The distance between detections for clustering
        ClusterSize = 4.7;
    end
    
    properties(Constant, Access=protected)
        pBusPrefix = 'BusClusterDetections'
    end
    
    methods
        function obj = helperClusterDetections(varargin)
            % Constructor
            setProperties(obj,nargin,varargin{:});
        end
    end
    
    methods(Access=protected)

        function [out, argsToBus] = defaultOutput(obj)
            busIn = propagatedInputBus(obj,1);
            if ~isempty(busIn)
                out = Simulink.Bus.createMATLABStruct(busIn);
            else
                out = repmat(struct,0,1);
            end
            
            numDets = 0;
            isValidTime = 0;
            argsToBus = {numDets, isValidTime};
        end
        
        % Currently only support simulink environment, so nothing to do
        % here
        function y = sendToBus(~,x,varargin)
            y = x;
        end
        
        function detBusOut = stepImpl(obj,detBusIn)
            
            numDetsIn = detBusIn.NumDetections;
            detsIn = detBusIn.Detections(1:numDetsIn);
            detsClust = localClusterDetections(detsIn, obj.ClusterSize);
            
            numDetsOut = numel(detsClust);
            
            detBusOut = detBusIn;
            detBusOut.NumDetections = numDetsOut;
            detBusOut.Detections(1:numDetsOut) = detsClust;
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end
        
        function dt = getOutputDataTypeImpl(obj)
            dt = getOutputDataTypeImpl@matlabshared.tracking.internal.SimulinkBusUtilities(obj);
        end
        
        function str = getIconImpl(~)
            str = sprintf('Detection\nClustering');
        end
        
        function varargout = getInputNamesImpl(~)
            varargout = {'In'};
        end
        
        function varargout = getOutputNamesImpl(~)
            varargout = {sprintf('Out')};
        end
    end
    
    methods(Static, Access=protected)
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(...
                'Title', 'DetectionClustering', ...
                'Text', getHeaderText());
        end
        function groups = getPropertyGroupsImpl
            pList = {'ClusterSize'};
            pSection = matlab.system.display.Section('PropertyList',pList);

            slBusSection = getPropertyGroupsImpl@matlabshared.tracking.internal.SimulinkBusUtilities;
            
            groups = [pSection, slBusSection];
        end
    end
end

function detectionClusters = localClusterDetections(detections, vehicleSize)
N = numel(detections);
if N < 1
    detectionClusters = detections;
    return
end
distances = zeros(N);
for i = 1:N
    for j = i+1:N
        if detections(i).SensorIndex == detections(j).SensorIndex
            distances(i,j) = norm(detections(i).Measurement(1:2) - detections(j).Measurement(1:2));
        else
            distances(i,j) = inf;
        end
    end
end
leftToCheck = 1:N;
i = 0;
detectionClusters = detections;
while ~isempty(leftToCheck)    
    % Remove the detections that are in the same cluster as the one under
    % consideration
    underConsideration = leftToCheck(1);
    clusterInds = (distances(underConsideration, leftToCheck) < vehicleSize);
    detInds = leftToCheck(clusterInds);
    
    ind = detInds(1);
    clusterMeas = detections(ind).Measurement;
    for m = 2:numel(detInds)
        ind = detInds(m);
        clusterMeas = clusterMeas + detections(ind).Measurement;
    end
    meas = clusterMeas/numel(detInds);
    
    i = i + 1;
    detectionClusters(i) = detections(detInds(1));
    detectionClusters(i).Measurement = meas;
    leftToCheck(clusterInds) = [];    
end
detectionClusters(i+1:end) = [];

% Since the detections are now for clusters, modify the noise to represent
% that they are of the whole car
for i = 1:numel(detectionClusters)
    measNoise = detectionClusters(i).MeasurementNoise;
    measNoise(1:2,1:2) = vehicleSize^2 * measNoise(1:2,1:2);
    measNoise(4:5,4:5) = vehicleSize^2 * 100 * measNoise(4:5,4:5);
    detectionClusters(i).MeasurementNoise = measNoise;
end
end

function str = getHeaderText
str = sprintf([...
    'The Detections Clustering block clusters all the detections generated by a ',...
    'sensor detection generator(usually, radarDetectionGenerator) if the ',...
    'detections are within a certain distance, ClusterSize, from each other.\n\n',...
    'The detection generator must use ''Ego Cartesian'' coordinates for ',...
    'this block to work.']);
end