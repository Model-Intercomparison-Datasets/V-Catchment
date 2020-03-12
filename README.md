# V-catchment simulation with SHUD mdoel

***SHUD - Simulator of Hydrological Unstructured Domain.*** 

Website: [www.shud.xyz](www.shud.xyz)

Author: Lele Shu [www.shulele.net](www.shulele.net)



The V-Catchment (VC) experiment is a standard test case for numerical hydrological models to validate their performance for overland flow along a hillslope and in the presence of a river channel.
The VC domain consists of two inclined planes draining into a sloping channel. 

![vcat](Ref/Vcat.png)

Both hillslopes are $800 \times 1000 m$ with Manning's roughness $n=0.015$.  The river channel between the hillslopes is $20$ m wide and $1000$ m in length with $n=0.15$. The slope from the ridge to the river channel is 0.05 (in the $x$ direction), and the longitudinal slope (in the $y$ direction) is 0.02.

Rainfall in the VC begins at time zero at a constant rate of $18 mm/hr$ and stops after 90 min, producing $27$ mm of accumulated precipitation. Since evaporation and infiltration is not involved in this simulation, the total outflow from lateral boundaries and the river outlet must be the same as the total precipitation (following conservation of mass).  



## Shen(2010) result

I use SHUD model to repeat the VC experiment, there are several literatures did the same experiment, but only Shen(2010) export the flux on side-plane which is also useful to validate the modeling algorithm. 

![Shen2010](Ref/Shen2010.png)

However, the value of volume flux of side-plane in Shen(2010) is problematic. Lets explain: based on the Continuity Law, the total input (precipitation) must be equal to output (side-plane flow) or discharge (outlet flow). But the side-plane flux in Shen (2010) is 20 times less than the discharge. I assume Shen made a wrong unit conversion somehow. When I enlarge the side-plane flux by 20, the flux rate and accumulated flux are rational. I tried to contact Shen, but he didn't reply with explanation, so I continue the work with my understanding.

The result figure (last figure in this file) also supports my thought. The side-plane flux in the result figure is the modified value (Shen's side-plane flux times 20). Both flow rate meet the Continuity Law. So, I think this is the right interpretation of Shen's result.



## R scripts

The R scripts include:

1. Build the V-catchment
2. Generate the physical and model parameters
3. Run simulations.
4. Visulize results
5. Compare the result with literature (Shen2010).

![shuddomain](Figure/vc_mesh.png)

## Data

1. Input files for SHUD model.
2. Result files from SHUD model.
3. Digitalized data from Shen2010.

![vcat_vs_vs](Figure/vcat_vs_vs.png)

## Policy

The script and data are open access for any purposes. I would be most grateful if you could send me an email (at lele.shu@gmail.com) when they helps you.

