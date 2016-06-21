function displayResults(results, getAccuracies)

if ~exist('collectAccuracies', 'var')
    getAccuracies = @collectAccuracies;
end
if ~iscell(results)
    results = {results};
end

%% Prepare
percentsBlack = [65:5:95, 99];
percentsVisible = NaN(size(percentsBlack));
percentsRanges = NaN([numel(percentsVisible), 2]); % range x left, right
kfolds = length(results);
classifierNames = unique(results{1}.name);
chanceLevel = 100 / length(unique(results{1}.truth));
accuracies = zeros(length(percentsVisible), length(classifierNames), ...
    kfolds);
for iBlack = 1:length(percentsBlack)
    [blackMin, blackMax, blackCenter, rangeLeft, rangeRight] = ...
        getPercentBlackRange(percentsBlack, iBlack);
    percentsRanges(iBlack, 1) = rangeLeft;
    percentsRanges(iBlack, 2) = rangeRight;
    percentsVisible(iBlack) = 100 - blackCenter;
    accuracies(iBlack, :, :) = getAccuracies(results, ...
        blackMin, blackMax, classifierNames);
end
dimKfolds = 3;
meanValues = mean(accuracies, dimKfolds, 'omitnan');
standardErrorOfTheMean = std(accuracies, 0, dimKfolds, 'omitnan') / ...
    sqrt(kfolds);

%% Graph
% plots
xlim([min(percentsVisible) - 3, max(percentsVisible) + 8]);
x = permute(repmat(percentsVisible, length(classifierNames), 1), [2 1]);
xLeftError = repmat(percentsRanges(:, 1), 1, length(classifierNames));
xRightError = repmat(percentsRanges(:, 2), 1, length(classifierNames));
errorbarxy(x, meanValues, ...
    xLeftError, xRightError, ...
    standardErrorOfTheMean, standardErrorOfTheMean, 'o-');
hold on;
plot(get(gca,'xlim'), [chanceLevel chanceLevel], '--k');
xlabel('Percent Visible');
ylabel('Performance');
% text labels
for i = 1:size(classifierNames)
    text(percentsVisible(1) + 1, meanValues(1, i), ...
        strrep(classifierNames{i}, '_', '\_'));
end
% human
if chanceLevel == 20
    ylim([0 100]);
    plotHumanPerformance(percentsBlack);
end
hold off;
