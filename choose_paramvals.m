% Make agents choose an action

% INPUTS
% expMerit - the cell array of the expected merit of each choice for a variable, each cell containing a Q-table
% completion - the completion of the learning cycle
% TMin, the minimum temperature for 

% OUTPUTS
% x - column vector of integers, element i corresponds to the chosen value
% for the variable i.
function x = choose_paramvals(expMerit, completion,TMin)
    
    % initialize vector of integers corresponding to the choices for each
    % parameter
    numChoices = numel(expMerit);
    x = uint8(zeros(numChoices, 1));
    
    % Iterate through the variables
    for ag = 1:numel(expMerit)
        
            % merit function for that specific variable
            % NOTE: the sign is inverted so that the best value is chosen
            % (since the best has the lowest objective value)
            merit = -expMerit{ag};

            %calculating T for exploration
            nu=TMin*log(2.0);
            T=nu/log(1.00001+completion);
            
            %softmax normalization
            merit2=1./(1+exp(-(merit-mean(merit))/(std(merit)+0.1)));
            
            %softmax selection (Note: a lower value in the merit function 
            %corresponds to a lower value of the objective function, makeing
            %)
            p= exp(merit2./(T));                  
            p=p/sum(p);
            
            %chooses value for the variable if softmax breaks
            ChosenValue = find(isnan(p));
            
            if isempty(ChosenValue)
                % Pick an action according to the probabilities in p
                try
                    ChosenValue = randsample(1:numel(merit), 1, true, p);
                catch
                    p % in case it produces a complex number
                    ChosenValue = randsample(1:numel(merit), 1, true, p);
                end
            else
                disp('Softmax broke due to infinite exponential!')
                disp('Picking between three best')
                [sorting,ranking]=sort(merit);
                dice=randi(20,1);
                if dice<=16
                    ChosenValue=ranking(1);
                elseif 16<dice<=19
                    ChosenValue=ranking(2);
                else 
                    ChosenValue=ranking(3);
                end
                    
            end
            
            if completion==1
                [~,ChosenValue]=max(p);
            end
            x(ag) = ChosenValue;   
            clear p
    end
end