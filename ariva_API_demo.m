%% Data extraction from Ariva
% Demo file
%

%% Ariva API class

% Create an arivaAPI class object
arivaObj = arivaAPI;

% Set the arivaAPI object properties
% Different identifier for stockName properties
arivaObj.stockName = {'dax','Dow Jones Industrial Average','FR0003500008'};
arivaObj.startDate = '1.1.2017';
arivaObj.endDate = '1.1.2018';

% Get indices constituents
constituents = arivaObj.getConstituents;

% Retrieve daily historical data for constituents of the dax index
arivaObj.stockName = constituents{:,1};
historicalData = arivaObj.getHistData;


%% Possible stockName properties

arivaObj.stockName = {'1000_gramm_silberbarren','DE000A0Z2ZZ5',...
             'DE0008469008','nordex','adidas','DAX',...
             'dow-jones-industrial-average','eurostoxx-50',...
             'steinhoff international holdings n.v.',...
             '1000_gramm_silberbarren','Goldpreis-Gold','ether',...
             'eur-jpy-euro-japanischer_yen'};
historicalDataMix = arivaObj.getHistData;





