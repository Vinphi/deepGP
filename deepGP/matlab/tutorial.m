% TUTORIAL Demonstration of deep GPs in various scenarios.
%
% DESC Demonstration of deep GPs in various scenarios.
%
% COPYRIGHT: Andreas C. Damianou, 2013
%
% DEEPGP

%% --------------   TOY UNSUPERVISED LEARNING DEMO ------------------------%
clear; close all
fprintf(1,['', ...
 '#####  Toy unsupervised (dimensionality reduction) demo: ####\n', ...
 '\n', ...
 'The deep GPs are first tested on toy data, created by stampling\n', ...
 'from a three-level stack of GPs. The true hierarchy is depicted\n', ...
 'in the demo, once the deep GP is trained. In short, from the top latent\n', ...
 'layer (X2) two intermediate latent signals are generated (XA and XB). \n', ...
 'These, in turn, together generate 10-dimensional observations\n', ...
 '(YA, YB) through sampling of another GP. These observations are then\n', ...
 'used to train the following models: a deep GP, a simple stacked PCA\n', ...
 'and a stacked Isomap method. From these models, only the deep GP\n', ...
 'marginalises the latent spaces and, in contrast to the other two,\n', ...
 'it is not given any information about the dimensionality of each true\n', ...
 'signal in the hierarchy; instead, this is learnt automatically\n', ...
 'through ARD.\n', ...
 '\n', ...
 'The deep GP finds the correct dimensionality for each\n', ...
 'hidden layer, but it also discovers latent signals which are closer\n', ...
 'to the real ones.\n', ...
 '\n', ...
  'The model can be parametrized in many ways, and the demo here considers\n',...
 'a basic parameterization. You can experiment with different latent space\n', ...
 'initialisations, different kernels (linear, non-linear, etc).\n',...
 'For other possible options check ''hsvargplvm_init.m'' and the various demos.\n']);

fprintf('\n# Press any key to start demo...\n')
pause
clear; close all
demToyUnsupervised; % Call to the demo

fprintf('\n\n');


%% -----------------    TOY REGRESSION DEMO -------------------------------%
fprintf(1,['', ...
 '#####  Toy regression demo: ####\n', ...
 'This is a simple regression demo which uses a toy dataset of\n', ...
 'input-output pairs [X0, Y] generated as follows: given an initial equally\n', ...
 'spaced input X_0, we feed this to a GP from which we sample outputs\n',...
 'X_1. These are in turn fed to another GP from which we sample outputs\n', ...
 'Y. Deep GPs (that use sparse GP apprpoximations by default) are compared', ...
 'to full (non-sparse) GPs (aka ''ftc'') and to sparse GPs with the ''fitc''', ...
 'approximation.\n', ...
 '\n', ...
 'The above experiment is run multiple times with random sets, and the\n',...
 'results are plotted for every trial.\n',...
 '\n', ...
 'Modeling-wise, this demo differs from the unsupervised learning one in that\n', ...
 'the deep GP has obserbed inputs on the top layer. Then, the kernel used for\n', ...
 'the mapping between the top layer and the one below, couples all inputs.\n',...
 '\n', ...
 'The models can be parametrized in many ways, and the demo here considers\n',...
 'a basic parameterization. You can experiment with different latent space\n', ...
 'initialisations, different kernels (linear, non-linear, etc).\n',...
 'For other possible options check ''hsvargplvm_init.m'' and the various demos.\n', ...
 '\n', ...
 'Here we set a large number of iterations for the deep GPs, since their converge\n', ...
 'is much slower (the other baselines are run until convergence). But you can still\n', ...
 'get reasonable results even by reducing a lot the number of iterations\n', ...
 'with initVardist and itNo, e.g. itNo = [5000 2000]; (or even less)\n']);
 
fprintf('\n# Press any key to start demo...\n')
pause
clear; close all
pause(1)
dFile = ['demoRegression1.txt']; % Diary file
delete(dFile); diary(dFile)
% File which stores the results
fName = ['demoRegressionErrors.txt'];
% Warped  GPs with temporal constraints
runVGPDS=0;
% Initialise the error vectors
eGP = []; eGPfitc = []; eRecGP = []; eDeepGP = []; eDeepGPNoCovars = [];
eDeepGPIn =[]; eRecDeepGP = []; eRecDeepGPNoCovars = []; eVGPDS = [];
eVGPDSIn = []; eRecVGPDS = []; eMean = []; eLinReg = [];
for experimentNo=[1:15];
	keep('fName', 'experimentNo', 'runVGPDS', 'eMean', 'eLinReg', 'eGP', 'eGPfitc', 'eRecGP', 'eDeepGP', 'eDeepGPNoCovars', 'eDeepGPIn', 'eRecDeepGP', 'eRecDeepGPNoCovars', 'eVGPDS', 'eVGPDSIn', 'eRecVGPDS');
	% Different random seed depending on the experiment id
    randn('seed', 6000+experimentNo); rand('seed', 6000+experimentNo);
    % The kernel to be used in the uppermost level
	dynamicKern = {'lin','white','bias'};
    % Number of iterations performed for initialising the variational
    % distribution, and number of training iterations
	initVardistIters = 1100;  itNo = [2000 5000 2000 2000 2000 2000 2000 2000 2000]; % Changed this
	H=2;  % Number of layers
	initSNR = {100, 100}; % Initial Signal To Noise ration per layer
    toyType='hierGpsNEW';
	Ntr=25; Dtoy=10; % Number of training data and dimensionality of outputs
	K=25; % Number of inducing points to use
	Q=8; % Dimensionality of latent space (can potentially be different per layer)
	initX='inputsOutputs'; % Initialise X with X0
	learnInducing=1; % Learning the inducing points
	runGP=1; runVGPDS=0;  % Compare with GPs and/or VGPD
	errorInRun = 0; % Flag
	try  
		demToyRegression; % Run the main demo
	catch e
		errorInRun = 1;
		fprintf(1, ['Error in experimentNo = ' num2str(experimentNo)])
	end
	if ~errorInRun
        % Print on screen and in a file the diagnostics and errors
		hsvargplvmShowSNR(model);
		ff = fopen(fName, 'w');
		eMean = [eMean errorMean]; fprintf(ff, 'errorMean = ['); fprintf(ff, '%.4f ', eMean); fprintf(ff,'];\n');
		eLinReg = [eLinReg errorLinReg]; fprintf(ff, 'errorLinReg = ['); fprintf(ff, '%.4f ', eLinReg); fprintf(ff,'];\n');
		eGP = [eGP errorGP]; fprintf(ff, 'errorGP = ['); fprintf(ff, '%.4f ', eGP); fprintf(ff,'];\n');
		eGPfitc = [eGPfitc errorGPfitc]; fprintf(ff, 'errorGPfitc = ['); fprintf(ff, '%.4f ', eGPfitc); fprintf(ff,'];\n');
    	eRecGP = [eRecGP errorRecGP]; fprintf(ff, 'errorRecGP = ['); fprintf(ff, '%.4f ', eRecGP); fprintf(ff,'];\n');
		eDeepGP = [eDeepGP errorDeepGP]; fprintf(ff, 'errorDeepGP = ['); fprintf(ff, '%.4f ', eDeepGP); fprintf(ff,'];\n');
		eDeepGPNoCovars = [eDeepGPNoCovars errorDeepGPNoCovars]; fprintf(ff, 'errorDeepGPNoCovars = ['); fprintf(ff, '%.4f ', eDeepGPNoCovars); fprintf(ff,'];\n');
		eDeepGPIn = [eDeepGPIn errorDeepGPIn]; fprintf(ff, 'errorDeepGPIn = ['); fprintf(ff, '%.4f ', eDeepGPIn); fprintf(ff,'];\n');
		eRecDeepGP = [eRecDeepGP errorRecDeepGP]; fprintf(ff, 'errorRecDeepGP = ['); fprintf(ff, '%.4f ', eRecDeepGP); fprintf(ff,'];\n');
		eRecDeepGPNoCovars = [eRecDeepGPNoCovars errorRecDeepGPNoCovars]; fprintf(ff, 'errorRecDeepGPNoCovars = ['); fprintf(ff, '%.4f ', eRecDeepGPNoCovars); fprintf(ff,'];\n');
		if runVGPDS
			eVGPDS = [eVGPDS errorVGPDS]; fprintf(ff, 'errorVGPDS = ['); fprintf(ff, '%.4f ', eVGPDS); fprintf(ff,'];\n');
			eVGPDSIn = [eVGPDSIn errorVGPDSIn]; fprintf(ff, 'errorVGPDSIn = ['); fprintf(ff, '%.4f ', eVGPDSIn); fprintf(ff,'];\n');
			eRecVGPDS = [eRecVGPDS errorRecVGPDS]; fprintf(ff, 'errorRecVGPDS = ['); fprintf(ff, '%.4f ', eRecVGPDS); fprintf(ff,'];\n');
		end
		fclose(ff);
	end
end
diary off

%%% Plots
fprintf('\n\n');
tt = 1:length(eMean);
plotFields = {'eMean','eLinReg','eGP', 'eGPfitc', 'eDeepGP'};
symb = getSymbols(length(plotFields));
for i=1:length(plotFields)
	plot(tt, eval(plotFields{i}), [symb{i} '-']); hold on;
	fprintf(1,'Mean error %s: %.4f\n', plotFields{i}, mean(eval(plotFields{i})))
end
legend(plotFields);

fprintf('\n\n');


%% --------  Collection of demos on digit data (demonstration) ----------------------%
fprintf(1,['', ...
 '#####  Digits demo collection: ####\n', ...
 'This is a collection of demos on the digit data. For this demonstration\n', ...
 'we use the pre-trained model discussed in the paper (5 level hierarchy).\n']);

fprintf('\n# Press any key to start demo...\n')
pause
clear; close all
demDigitsDemonstration