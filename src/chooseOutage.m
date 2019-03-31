function [ mpr, report ] = chooseOutage(mpr, hPlot, hGraph)
%chooseOutage Interaktywny wybor linii do wylaczenia.
%   Funkcja wyszukuje minimaln� odleg�o�� mi�dzy �rodkiem ka�dej linii
%   grafu, a wsp�rz�dn� pobran� od u�ytkownika. Na tej podstawie
%   wyszukiwany jest numer linii do wy��czenia (BR_STATUS = 0)
%   LPM - wyb�r linii do wy��czenia
%   PPM - anulowanie ostatniego wyboru
%   SPACE - wyj�cie z funkcji

    define_constants

    ftb=[mpr.branch(:,F_BUS) mpr.branch(:,T_BUS)];
    [~,ig,ib] = intersect(hGraph.Edges.EndNodes,ftb,'rows','stable');

    %Zamiana zmiennych tekstowych w parametrze "NodeLabel" na zmienne typu num
    tempG = table2array(hGraph.Edges);
    nodeId = cellfun(@str2num, hPlot.NodeLabel);

    %p�tla w kt�rej uzyskuje si� wsp�rz�dne x,y w�z�a fromBus i toBus
    sizeG = size(tempG,1);
    %prelokacja zmiennych
    xCenter = zeros(1,sizeG);
    yCenter = zeros(1,sizeG);

    for i = 1:sizeG
    xFrom = hPlot.XData(nodeId == tempG(i,1));
    yFrom = hPlot.YData(nodeId == tempG(i,1));
    xTo = hPlot.XData(nodeId == tempG(i,2));
    yTo = hPlot.YData(nodeId == tempG(i,2));
    xCenter(i) = (xFrom+xTo)/2; 
    yCenter(i) = (yFrom+yTo)/2;
    end

    %zmienne dla przypadku: PPM
    copyBrStatus = mpr.branch(:, BR_STATUS);
    copyLineStyle = hPlot.LineStyle;

    %nadanie zmiennej wartosci paczatkowej
    clicButton = 1;

    while clicButton ~= 32      % Spacja zeby wyjsc z petli
        [clicX, clicY, clicButton] = ginput(1);

        switch clicButton
        case 1     % LPM
           %Obliczneie d�ugo�ci euklidesowej i wyszukanie minimum 
           length = sqrt((clicX- xCenter).^2+(clicY- yCenter).^2);
           %poprawic moga byc bledy-->
           [minValB,~] = min(length(ig));
           minIdB = find(length(ig)==minValB);
           minIdG = find(length==minValB);
           mpr.branch(minIdB, BR_STATUS) = 0;
           highlight(hPlot, hGraph.Edges.EndNodes(minIdG,1), hGraph.Edges.EndNodes(minIdG,2),...
               'LineStyle',':')

        case 3     % PPM
            mpr.branch(:, BR_STATUS) = copyBrStatus;
            hPlot.LineStyle = copyLineStyle;
        otherwise
            ...
        end
    end
    %Na potrzeby raportu
    report = mpr.branch(xor(mpr.branch(:,BR_STATUS), copyBrStatus),:);
    % mpr = isolateBus(mpr);
end

