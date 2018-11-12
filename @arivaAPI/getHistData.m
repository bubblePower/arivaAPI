function data = getHistData(obj)
    stockName = obj.stockName;
    startDate = obj.startDate;
    endDate = obj.endDate;
    % Define output variable
    data = struct;
    stockNameList = reshape(stockName,[],1);
    sList = size(stockNameList,1);
    
    %% Extract ariva individual security ID and suggested exchange ID
    secur = cell(sList,1);
    exchangeID = cell(sList,1);
    for s=1:sList
        try
            url = ['http://www.ariva.de/', stockNameList{s,1}, '-aktie/historische_kurse'];
            dataHtml = webread(url);
        catch 
            try
                url = ['http://www.ariva.de/', stockNameList{s,1}, '-kurs/historische_kurse'];
                dataHtml = webread(url);
            catch
                url = ['http://www.ariva.de/', stockNameList{s,1}, '/historische_kurse'];
                dataHtml = webread(url);
            end
        end
        secur{s,1} = extractBetween(dataHtml, strcat(char(39),'AIC',char(39),', [',char(39)), strcat(char(39),']'));  
        exchangeID{s,1} = extractBetween(dataHtml,'boerse_id=','"');
    end
    
    %% Download historical data for a list of assets
    for s=1:sList
        % retrieve historical data
        listUrl = ['http://www.ariva.de/quote/historic/historic.csv?secu=',secur{s,1},...
            '&boerse_id=',exchangeID{s,1},...
            '&clean_split=ARRAY(0x7f4d5836a0b0)',...
            '&clean_payout=ARRAY(0x7f4d586d80e8)',...
            '&clean_bezug=ARRAY(0x7f4d59c27400)',...
            '&currency=EUR&',...
            'min_time=',startDate,...
            '&max_time=',endDate,...
            '&trenner=','|',...
            '&go=Download'];
        urlHist = join(listUrl,'');
        options = weboptions('ArrayFormat','csv','ContentType','text');
        dataHistText = webread(urlHist{1,1},options);
        filename = 'dataH.txt';
        dlmwrite(filename,dataHistText,'',[],7);
        dataHistory = flipud(importfile(filename));
        data.(regexprep(char(stockNameList{s,1}),{'\<^[0-9]*','[^a-zA-Z0-9]'},'')) = dataHistory;
    end

end

