function output = RtoT_cal_inputRT(R,T, option, order,interpopt,modelopt,fitseed)

% This function processes files which contain datacells


%% Feed this function:
% --------------------------------------------------
% fileroot : where to look for files
% filenames : a cell of filenames to use in the fit
% tempCellName : name of the datacell entry i.e. (BathTemp etc)corresponding to T
% resCellName : name of the datacell entry corresponding to R
% option : what to do with the data (see below)
% order : order of the log-space polynomial fit
% interpopt : Allows for interpolating input dataset so that points are
% distributed evenly and certain regions don't get overfit.

%% Load and Sort all the relevant data





% %% fit model (regular polynomial)
% spc = 2; inc = (10^(-spc));
% Xi = round(min(log(R)),spc);
% Xf = round(max(log(R)),spc);
% X = [Xi+inc:inc:Xf-inc];
% Y = Interp1NonUnique(log(R),log(T),X);
%
% p = polyfit(X,Y,order);
% f = fittype('a*exp(polyval(p,log(x)))');
% pfit = cfit(f,1,p);


%% fit model (cheby)
switch modelopt
    case 'Polynomial'
        spc = 2; inc = (10^(-spc));
        Xi = round(min(log(R)),spc);
        Xf = round(max(log(R)),spc);
        X = [Xi+inc:inc:Xf-inc]; % Interpolated Log R
        Y = Interp1NonUnique(log(R),log(T),X); % Interpolated Log T
        
        p = polyfit(X,Y,order); 
        f = fittype('a*exp(polyval(p,log(x)))');
        pfit = cfit(f,1,p);
        output=pfit;
        c=pfit;
    case 'Chebyshev'
        spc = 2; inc = (10^(-spc));
        ZL = round(min(log10(R)),spc)-inc;
        ZU = round(max(log10(R)),spc)+inc;
        letter = {'a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v','w','z'};
        
        Xstr =  ['(2*log10(x)-' num2str(ZL + ZU) ')/',...
            '(' num2str(ZU - ZL) ')'];
        Tstr = [];
        for j = 0:order
            Tstr = [Tstr '+' letter{j+1} '*' 'chebyshevT(' num2str(j) ',' Xstr ')'];
        end
        ft = fittype(Tstr);
        [xData, yData] = prepareCurveData( R , T );
        if strcmp(interpopt,'Yes')
            interpRs=exp(linspace(log(min(R)),log(max(R)),3000));
            interpT=Interp1NonUnique(R,T,interpRs);
            [xData, yData] = prepareCurveData( interpRs , interpT );
        end
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        c = fit( xData, yData, ft, opts );
        % chebfit = cfit(ft,coeffvalues(c));
        output=c;
    case 'Chebyshev Feed LogRes'
        spc = 2; inc = (10^(-spc));
        ZL = round(min(log10(R)),spc)-inc;
        ZU = round(max(log10(R)),spc)+inc;
        letter = {'a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v','w','z'};
        
        Xstr =  ['(2*x-' num2str(ZL + ZU) ')/',...
            '(' num2str(ZU - ZL) ')'];
        Tstr = [];
        for j = 0:order
            Tstr = [Tstr '+' letter{j+1} '*' 'chebyshevT(' num2str(j) ',' Xstr ')'];
        end
        ft = fittype(Tstr);
        [xData, yData] = prepareCurveData( log10(R) , T );
        if strcmp(interpopt,'Yes')
            display('interpolating')
            interpRs=exp(linspace(log(min(R)),log(max(R)),3000));
            interpT=Interp1NonUnique(R,T,interpRs);
            [xData, yData] = prepareCurveData( log10(interpRs) , interpT );
        end
        opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
        opts.Display = 'Off';
        c = fit( xData, yData, ft, opts );
        % chebfit = cfit(ft,coeffvalues(c));
        output=c; 
    case 'Chebyshev Feed LogRes, Seed fitvals'
        spc = 2; inc = (10^(-spc));
        ZL = round(min(log10(R)),spc)-inc;
        ZU = round(max(log10(R)),spc)+inc;
        letter = {'a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v','w','z'};
        
        Xstr =  ['(2*x-' num2str(ZL + ZU) ')/',...
            '(' num2str(ZU - ZL) ')'];
        Tstr = [];
        for j = 0:order
            Tstr = [Tstr '+' letter{j+1} '*' 'chebyshevT(' num2str(j) ',' Xstr ')'];
        end
        ft = fittype(Tstr);
        [xData, yData] = prepareCurveData( log10(R) , T );
        if strcmp(interpopt,'Yes')
            display('interpolating');
            interppoints=1000; %3000 until 10/3
            interpRs=exp(linspace(log(min(R)),log(max(R)),interppoints));
            interpT=Interp1NonUnique(R,T,interpRs);
            [xData, yData] = prepareCurveData( log10(interpRs) , interpT );
        end
        pos=2;
        neg=1-(pos-1);
%         opts = fitoptions( 'Method', 'NonlinearLeastSquares','StartPoint',fitseed,...
%             'Lower',[fitseed(1)*neg fitseed(2)*pos fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
%             'Upper',[fitseed(1)*pos fitseed(2)*neg fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
        opts = fitoptions( 'Method', 'NonlinearLeastSquares','StartPoint',fitseed);
%             'Lower',[fitseed(1)*neg fitseed(2)*pos fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
%             'Upper',[fitseed(1)*pos fitseed(2)*neg fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
%    
% %                     'Lower',[fitseed(1) fitseed(2) fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
% %             'Upper',[fitseed(1) fitseed(2) fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
% %         
        
        opts.Display = 'Off';
        disp('Fitting...');
        c = fit( xData, yData, ft, opts );
        % chebfit = cfit(ft,coeffvalues(c));
        output=c; 
    case 'Chebyshev Feed Res, Seed fitvals'
        spc = 2; inc = (10^(-spc));
        ZL = round(min(log10(R)),spc)-inc;
        ZU = round(max(log10(R)),spc)+inc;
        letter = {'a','b','c','d','e','f','g','h','k','l','m','n','o','p','q','r','s','t','u','v','w','z'};
        
        Xstr =  ['(2*log10(x)-' num2str(ZL + ZU) ')/',...
            '(' num2str(ZU - ZL) ')'];
        Tstr = [];
        for j = 0:order
            Tstr = [Tstr '+' letter{j+1} '*' 'chebyshevT(' num2str(j) ',' Xstr ')'];
        end
        ft = fittype(Tstr);
        [xData, yData] = prepareCurveData( R , T );
        if strcmp(interpopt,'Yes')
            interpRs=exp(linspace(log(min(R)),log(max(R)),1000));
            interpT=Interp1NonUnique(R,T,interpRs);
            [xData, yData] = prepareCurveData( interpRs , interpT );
        end
%         opts = fitoptions( 'Method', 'NonlinearLeastSquares','StartPoint',fitseed,...
%             'Lower',[fitseed(1)*neg fitseed(2)*pos fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
%             'Upper',[fitseed(1)*pos fitseed(2)*neg fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
        opts = fitoptions( 'Method', 'NonlinearLeastSquares','StartPoint',fitseed);
%             'Lower',[fitseed(1)*neg fitseed(2)*pos fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
%             'Upper',[fitseed(1)*pos fitseed(2)*neg fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
%    
% %                     'Lower',[fitseed(1) fitseed(2) fitseed(3)*neg fitseed(4)*pos fitseed(5)*neg fitseed(6)*neg],...
% %             'Upper',[fitseed(1) fitseed(2) fitseed(3)*pos fitseed(4)*neg fitseed(5)*pos fitseed(6)*pos]);
% %         
        
        opts.Display = 'Off';
        disp('Fitting...');
        c = fit( xData, yData, ft, opts );
        % chebfit = cfit(ft,coeffvalues(c));
        output=c; 
    case 'Smoothing Spline'
        [xData, yData] = prepareCurveData( R , T );
        ft = fittype( 'smoothingspline' );
        opts = fitoptions( 'Method', 'SmoothingSpline' );
        opts.SmoothingParam = 0.837805372983563;
        if strcmp(interpopt,'Yes')
            interpRs=linspace(min(R),max(R),3000);
            interpT=Interp1NonUnique(R,T,interpRs);
            [xData, yData] = prepareCurveData( interpRs , interpT );
        end
        % Fit model to data.
        c = fit( xData, yData, ft, opts );
        output = c;
    otherwise 
        display(sprintf('Please select a valid option:\n -Polynomial-\n -Chebyshev- \n -Chebyshev Feed LogRes-\n -Smoothing Spline-')); 
end




%% Processing
switch option
    
    case 'plotRvT'
        if strcmp(modelopt,'Chebyshev Feed LogRes')
        h1 = figure;
        hold on;
        subplot(2,1,1); hold on;
        plot(R,T,'gsq');
        %plot(R,pfit(R),'r--');
        plot(R,c(log10(R)),'r--');
        ylabel('T_{Samp}'); xlabel('R_{CX}');
        legend({'Raw Data','ChebyFit'});
        subplot(2,1,2); hold on;
        try
            plot(T,T-c(log10(R))); title('Residuals');
        catch
            plot(T,T-c(log10(R))'); title('Residuals');
        end
        xlabel('T [K]');
        else
        h1 = figure;
        hold on;
        subplot(2,1,1); hold on;
        plot(R,T,'gsq');
        %plot(R,pfit(R),'r--');
        plot(R,c(R),'r--');
        ylabel('T_{Samp}'); xlabel('R_{CX}');
        legend({'Raw Data','ChebyFit'});
        subplot(2,1,2); hold on;
        try
            plot(T,T-c(R)); title('Residuals');
        catch
            plot(T,T-c(R)'); title('Residuals');
        end
        xlabel('T [K]');
        end
        
        output = c;
        
    case 'fitRvT'
        
        h1 = figure;
        
        subplot(3,1,1); hold on;
        plot(log(R),log(T),'sq','Color','b'); hold on
        title('log(R_{CX}) v log(T_{Samp})')
        ylabel('log(T_{Samp})'); xlabel('log(R_{CXK})');
        plot(X,Y,'g.')
        plot(X,polyval(p,X),'r--');
        legend({'Raw Data','Interpolation','Polyfit'})
        
        subplot(3,1,2);
        fitT = pfit(R)';
        plot(log(R),(T-fitT)./T,'k+')
        title('Fit Model Residuals')
        xlabel('log(R_{Samp})'); ylabel('\Delta T/T');
        
        subplot(3,1,3);
        plot(fitT,(T-fitT)./T,'k+');
        xlabel('Fit T [K]'); ylabel('\Delta T/T'); 

        output = c;
        
    case 'getfit'
        
        output = c;
        
    case 'plotSens'
        h1 = figure;
        hold on
        plot(T,abs(1./differentiate(chfit,R)),'b');
        ylabel('|dR/dT| [\Omega/K]'); xlabel('T [K]');
        
    otherwise
        
        display('Invalid option: See (RtoT_cal.m) for ref.')
        
end

end