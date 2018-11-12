function dataH = importfile(filename)
    %IMPORTFILE Import numeric data from a text file as a matrix.
    %   DATAH = IMPORTFILE(FILENAME) Reads data from text file

    %% Initialize variables.
    delimiter = '|';
    startRow = 2;
    endRow = inf;

    %% Read columns of data as text:
    % For more information, see the TEXTSCAN documentation.
    formatSpec = '%s%s%s%s%s%s%s%[^\n\r]';

    %% Open the text file.
    fileID = fopen(filename,'r');

    %% Read columns of data according to the format.
    % This call is based on the structure of the file used to generate this
    % code. If an error occurs for a different file, try regenerating the code
    % from the Import Tool.
    textscan(fileID, '%[^\n\r]', startRow(1)-1, 'WhiteSpace', '', 'ReturnOnError', false);
    dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
    for block=2:length(startRow)
        frewind(fileID);
        textscan(fileID, '%[^\n\r]', startRow(block)-1, 'WhiteSpace', '', 'ReturnOnError', false);
        dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', delimiter, 'TextType', 'string', 'ReturnOnError', false, 'EndOfLine', '\r\n');
        for col=1:length(dataArray)
            dataArray{col} = [dataArray{col};dataArrayBlock{col}];
        end
    end

    %% Close the text file.
    fclose(fileID);

    %% Convert the contents of columns containing numeric text to numbers.
    % Replace non-numeric text with NaN.
    raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
    for col=1:length(dataArray)-1
        raw(1:length(dataArray{col}),col) = mat2cell(dataArray{col}, ones(length(dataArray{col}), 1));
    end
    numericData = NaN(size(dataArray{1},1),size(dataArray,2));

    for col=[2,3,4,5,6,7]
        % Converts text in the input cell array to numbers. Replaced non-numeric
        % text with NaN.
        rawData = dataArray{col};
        for row=1:size(rawData, 1)
            % Create a regular expression to detect and remove non-numeric prefixes and
            % suffixes.
            regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\.]*)+[\,]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\.]*)*[\,]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
            try
                result = regexp(rawData(row), regexstr, 'names');
                numbers = result.numbers;

                % Detected commas in non-thousand locations.
                invalidThousandsSeparator = false;
                if numbers.contains('.')
                    thousandsRegExp = '^\d+?(\.\d{3})*\,{0,1}\d*$';
                    if isempty(regexp(numbers, thousandsRegExp, 'once'))
                        numbers = NaN;
                        invalidThousandsSeparator = true;
                    end
                end
                % Convert numeric text to numbers.
                if ~invalidThousandsSeparator
                    numbers = strrep(numbers, '.', '');
                    numbers = strrep(numbers, ',', '.');
                    numbers = textscan(char(numbers), '%f');
                    numericData(row, col) = numbers{1};
                    raw{row, col} = numbers{1};
                end
            catch
                raw{row, col} = rawData{row};
            end
        end
    end

    % Convert the contents of columns with dates to MATLAB datetimes using the
    % specified date format.
    try
        dates{1} = datetime(dataArray{1}, 'Format', 'yyyy-MM-dd', 'InputFormat', 'yyyy-MM-dd');
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{1} = cellfun(@(x) x(2:end-1), dataArray{1}, 'UniformOutput', false);
            dates{1} = datetime(dataArray{1}, 'Format', 'yyyy-MM-dd', 'InputFormat', 'yyyy-MM-dd');
        catch
            dates{1} = repmat(datetime([NaN NaN NaN]), size(dataArray{1}));
        end
    end

    dates = dates(:,1);

    %% Split data into numeric and string columns.
    rawNumericColumns = raw(:, [2,3,4,5,6,7]);

    %% Create output variable
    dataH = table;
    try
        dataH.Date = dates{:, 1};
        dataH.Open = cell2mat(rawNumericColumns(:, 1));
        dataH.High = cell2mat(rawNumericColumns(:, 2));
        dataH.Low = cell2mat(rawNumericColumns(:, 3));
        dataH.AdjClose = cell2mat(rawNumericColumns(:, 4));
        dataH.Trades = cell2mat(rawNumericColumns(:, 5));
        dataH.Volume = cell2mat(rawNumericColumns(:, 6));
    catch
        try
            clear dataH
            dataH = table;
            dataH.Date = dates{:, 1};
            dataH.Open = cell2mat(rawNumericColumns(:, 1));
            dataH.High = cell2mat(rawNumericColumns(:, 2));
            dataH.Low = cell2mat(rawNumericColumns(:, 3));
            dataH.AdjClose = cell2mat(rawNumericColumns(:, 4));
            dataH.Volume = cell2mat(rawNumericColumns(:, 5));
        catch
            try
                clear dataH
                dataH = table;
                dataH.Date = dates{:, 1};
                dataH.Open = cell2mat(rawNumericColumns(:, 1));
                dataH.High = cell2mat(rawNumericColumns(:, 2));
                dataH.Low = cell2mat(rawNumericColumns(:, 3));
                dataH.AdjClose = cell2mat(rawNumericColumns(:, 4));
            catch
                emptyCell = cellfun(@isempty,raw);
                raw(emptyCell) = {NaN};
                rawNumericColumns = raw(:, [2,3,4,5,6,7]);
                clear dataH
                dataH = table;
                dataH.Date = dates{:, 1};
                dataH.Open = cell2mat(rawNumericColumns(:, 1));
                dataH.High = cell2mat(rawNumericColumns(:, 2));
                dataH.Low = cell2mat(rawNumericColumns(:, 3));
                dataH.AdjClose = cell2mat(rawNumericColumns(:, 4));
                dataH.Trades = cell2mat(rawNumericColumns(:, 5));
                dataH.Volume = cell2mat(rawNumericColumns(:, 6));  
            end
        end
    end
    % For code requiring serial dates (datenum) instead of datetime, uncomment
    % the following line(s) below to return the imported dates as datenum(s).

    % dataH.Datum=datenum(dataH.Datum);
end
