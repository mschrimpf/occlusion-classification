classdef RnnFeatureProvider < FeatureExtractor
    % Classifier that retrieves the RNN features from previous runs.
    % The format for the RNN is fundamentally different from the other
    % features (i.e. not split up into multiple files).
    
    properties
        occlusionData
        originalExtractor
        features
    end
    
    methods
        function self = RnnFeatureProvider(...
                occlusionData, originalExtractor)
            self.occlusionData = occlusionData;
            self.originalExtractor = originalExtractor;
            dir = getFeaturesDirectory();
            featuresFile = [dir, originalExtractor.getName() '.mat'];
            self.features = load(featuresFile);
            self.features = self.features.features;
        end
        
        function name = getName(self)
            name = self.originalExtractor.getName();
        end
        
        function features = extractFeatures(self, ids, runType, ~)
            switch(runType)
                case RunType.Train
                    features = self.features(...
                        self.occlusionData.pres(ids), :);
                case RunType.Test
                    features = self.features(325 + ids, :);
            end
        end
    end
end
