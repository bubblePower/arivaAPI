function stockList = getConstituents(obj)
    indexName = obj.stockName;
    % Define output variable
    indexNameList = reshape(indexName,[],1);
    sList = size(indexNameList,1);
    
    %% Extract constituents from index
    stockList = cell(1,sList);
    for s=1:sList
        try
            url = ['http://www.ariva.de/', indexNameList{s,1}, '-index/realtime-kurse?sort=change_rel&sort_d=desc&page_size=500'];
            html = webread(url);
            htmlText = string(extractBetween(html,'<a href="/','"'));
            stockList{1,s} = rmmissing(extractBefore(htmlText,'-aktie/news'));
        catch
            try
                url = ['https://www.ariva.de/', indexNameList{s,1}, '/realtime-kurse?sort=change_rel&sort_d=desc&page_size=500'];
                html = webread(url);
                htmlText = string(extractBetween(html,'<a href="/','"'));
                stockList{1,s} = rmmissing(extractBefore(htmlText,'-aktie/news'));
            catch
                warning('Problem using function getConstituents().');
                stockList{1,s} = NaN;
            end
        end
    end
end


function str = ReadUrl(url)
     is = java.net.URL([], url, sun.net.www.protocol.https.Handler).openConnection().getInputStream(); 
     br = java.io.BufferedReader(java.io.InputStreamReader(is));
     str = char(br.readLine());
 end