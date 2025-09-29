% C2.4, C2.6

get_VT;
CL_Trim = linspace(0.2, 1.8, 5);
eta_t_trim = [];
h = linspace(0.5, -0.5, 5);
counter = 0;

for j = 1:5
    for i = 1:5
        eta_T = 0;
        CM = 1;
        [Hn] = get_StaticMargin(h(i));
        StaticMargin(i) = Hn;

        while (CM > 0.01) || (CM < -0.01)
            counter = counter + 1;
            [CL_T] = get_tailCL(CL_Trim(i), eta_T);
            [CM] = getPitchingMomentCoefficient(CL_Trim(i), CL_T, h(j));

            if (CM < 0.01) && (CM > -0.01)
                eta_T_trim(i) = eta_T;
                
            elseif CM >0.01
                eta_T = eta_T + 0.0001;
            
            else
                eta_T = eta_T - 0.0001;
            end
        end
    end
    figure(1)
    plot(CL_Trim, eta_T_trim)
    hold on
    set(gca, "XTick", 0.1:0.1:1.8);
    xlabel("CL_t_r_i_m")
    ylabel("eta_t_r_i_m")
    title("eta_trim vs CL_trim")
end

f = figure(2)
plot(h, StaticMargin)
title("Static Margin vs CG position")
ylabel("Static Margin")
xlabel("CG Position")
movegui(f, [300, 0])
