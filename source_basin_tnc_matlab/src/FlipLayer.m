classdef FlipLayer < nnet.layer.Layer
%%  Data flip
    methods
        function layer = FlipLayer(name)
            layer.Name = name;
        end
        function Y = predict(~, X)
                 Y = flip(X, 3);
        end
    end
end
