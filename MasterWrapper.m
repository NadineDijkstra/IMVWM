% Root etc
root = 'C:\Users\ndijkstra\Dropbox\=OngoingProjects\IMVVWM';
cd(root);
addpath('Analyses');
data = fullfile(root,'Data','Data_diss.xlsx');

%% Read data
data = readtable(data);

% recode data
[~,~,subID] = unique(table2array(data(:,1)));
difficulty = double(strcmp(table2array(data(:,3)),'H'));
presented  = double(strcmp(table2array(data(:,4)),'CW'));
responded  = double(strcmp(table2array(data(:,5)),'CW'));
responded(strcmp(table2array(data(:,5)),'/')) = nan;
VVIQ       = table2array(data(:,6));

%% Analyse data
nsubs = length(unique(subID)); subIDs = unique(subID);
VVIQsub = nan(nsubs,1);
dp = nan(nsubs,2); 
c = nan(nsubs,2); % per difficulty level
acc = nan(nsubs,2);
for sub = 1:nsubs

    % select trials for that subject
    idx = find(subID==subIDs(sub));
    VVIQsub(sub) = VVIQ(idx(1));
    P = presented(idx); R = responded(idx); D = difficulty(idx);

    % per difficulty level
    for d = 1:2    
        Pd = P(D==(d-1)); Rd = R(D==(d-1));
        
        acc(sub,d) = mean(Pd==Rd);    

        FA = sum(Pd==0&Rd==1)/sum(Pd==1); 
        if FA==0; FA = 0.5/sum(Pd==1); 
        elseif FA==1; FA=sum(Pd==1)-0.5/sum(Pd==1); end
        H  = sum(Pd==1&Rd==1)/sum(Pd==1); 
        if H==0; H = 0.5/sum(Pd==1); 
        elseif H==1; H=(sum(Pd==1)-0.5)/sum(Pd==1); end

        [dp(sub,d),c(sub,d)] = dprime(H,FA);

    end

end

ima_group = nan(nsubs,1); 
ima_group(VVIQsub<=45) = 1;
ima_group(VVIQsub>45 & VVIQsub<65) = 2;
ima_group(VVIQsub>=71) = 3;

%% Group effects
figure;
subplot(3,1,1) % dp
M = nan(3,2); SEM = nan(3,2);
for ig = 1:3
    for d = 1:2
        M(ig,d) = mean(dp(ima_group==ig,d));
        SEM(ig,d) = std(dp(ima_group==ig,d))./sqrt(sum(ima_group==ig));
    end
end
barwitherr(SEM,M); title("d'"); 
set(gca,'XTickLabels',{'Low imagers','Controls','High imagers'});
legend('Easy','Hard');

subplot(3,1,2) % c
M = nan(3,2); SEM = nan(3,2);
for ig = 1:3
    for d = 1:2
        M(ig,d) = mean(c(ima_group==ig,d));
        SEM(ig,d) = std(c(ima_group==ig,d))./sqrt(sum(ima_group==ig));
    end
end
barwitherr(SEM,M); title("criterion"); 
set(gca,'XTickLabels',{'Low imagers','Controls','High imagers'});
legend('Easy','Hard');

subplot(3,1,3) % acc
M = nan(3,2); SEM = nan(3,2);
for ig = 1:3
    for d = 1:2
        M(ig,d) = mean(acc(ima_group==ig,d));
        SEM(ig,d) = std(acc(ima_group==ig,d))./sqrt(sum(ima_group==ig));
    end
end
barwitherr(SEM,M); title("accuracy"); 
set(gca,'XTickLabels',{'Low imagers','Controls','High imagers'});
legend('Easy','Hard'); ylim([0.5 1])

% Main accuracy plot
figure;
b = barwitherr(SEM,M,'LineWidth',2); title("Accuracy"); hold on;
plot([0.85 1.15],[acc(ima_group==1,1) acc(ima_group==1,2)],'k-','Marker','.','MarkerSize',20); hold on
plot([1.85 2.15],[acc(ima_group==2,1) acc(ima_group==2,2)],'k-','Marker','.','MarkerSize',20); hold on
plot([2.85 3.15],[acc(ima_group==3,1) acc(ima_group==3,2)],'k-','Marker','.','MarkerSize',20); hold on
ylim([0 1.1])

% VVIQ distirbutions plot
figure; nSubG = sum(ima_group==1);
plot(1+randn(nSubG,1)/25,VVIQsub(ima_group==1),'k','Marker','.','MarkerSize',15,'LineStyle','none'); hold on
boxplot(VVIQsub(ima_group==1),'positions',1,'symbol',' '); hold on
plot(2+randn(nSubG,1)/25,VVIQsub(ima_group==2),'k','Marker','.','MarkerSize',15,'LineStyle','none'); hold on
boxplot(VVIQsub(ima_group==2),'positions',2,'symbol',' '); hold on
plot(3+randn(nSubG,1)/25,VVIQsub(ima_group==3),'k','Marker','.','MarkerSize',15,'LineStyle','none'); hold on
boxplot(VVIQsub(ima_group==3),'positions',3,'symbol',' '); hold on

%% Correlations 
figure;
subplot(1,3,1);
scatter(dp(:,1),VVIQsub,40,'b','filled'); hold on;
scatter(dp(:,2),VVIQsub,40,'r','filled'); hold on;
l = lsline; l(1).LineWidth = 4; l(2).LineWidth = 4;
l(2).Color = [0 0 1]; l(1).Color = [1 0 0]; title('dp')

subplot(1,3,2);
scatter(c(:,1),VVIQsub,40,'b','filled'); hold on;
scatter(c(:,2),VVIQsub,40,'r','filled'); hold on;
l = lsline; l(1).LineWidth = 4; l(2).LineWidth = 4;
l(2).Color = [0 0 1]; l(1).Color = [1 0 0]; title('c')

subplot(1,3,3);
scatter(acc(:,1),VVIQsub,40,'b','filled'); hold on;
scatter(acc(:,2),VVIQsub,40,'r','filled'); hold on;
l = lsline; l(1).LineWidth = 4; l(2).LineWidth = 4;
l(2).Color = [0 0 1]; l(1).Color = [1 0 0]; title('Accuracy')

