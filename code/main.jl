using MAT
using Plots
using Measures
using Flux
using DifferentialEquations
using DiffEqFlux
using LaTeXStrings
using Random
using StatsPlots
using JLD
using StatsBase,Statistics
vars = matread("C:/Users/zhang/Desktop/投稿/data/new12city16-19.mat");
T = vars["temp"];
R = vars["rain"];
AT = vars["avetemp"];
AR = vars["averain"];
AD = vars["MOI"];
city = 12;
ann = Chain(Dense(2,10,sigmoid),Dense(10,10,sigmoid),Dense(10,1,sigmoid));
panu = 151;
p3n = load("C:/Users/zhang/Desktop/code/myparam/param.jld","param");
rate = load("C:/Users/zhang/Desktop/code/myparam/rate.jld","param");

p1,re = Flux.destructure(ann);
ann = re(p3n[1:panu])
p1,re = Flux.destructure(ann);
p3 = p1
ps = Flux.params(p3)

function Wen(du, u, p, t)
    rate2 = rate
    mup = min(max(rate2[1],0.8),1.0)
    tp = min(max(rate2[2],18),22)
    vp = min(max(rate2[3],5),20)
    mua = min(max(rate2[4],0.4),1.0)
    ta =  min(max(rate2[5],17),25)
    va =  min(max(rate2[6],5),20)     
    ax = min(max(rate2[7],0),0.97)
    hax = min(max(rate2[8],20000),30000)
    hhx = min(max(rate2[9],30000),40000)
    thx = min(max(rate2[10],290),313)
    r = min(max(abs(rate2[11]),0.0001),0.02)
    thred = 21
    u = u.*(u.>0)
    for i = 1:city  
        mu = ax*((T[i,floor(Int,t)]+273.15)/298.15)*(exp(hax/1.987*(1/298.15-1/(T[i,floor(Int,t)]+273.15))))/(1+exp(hhx/1.987*(1/thx-1/(T[i,floor(Int,t)]+273.15))))              
        mu = min(mu*(AT[i,ceil(Int,t/15)]>thred)+mu*r*(AT[i,ceil(Int,t/15)]<=thred),1)       
        ef = abs(exp(-0.1*(1+mu*u[i*2-1]/(250000*(1+AR[i,floor(Int,t)])))))      
        dp1 = abs(1-mup*exp(-(tp-T[i,floor(Int,t)])^2/(vp^2)))
        dp2 = abs(1-mup*exp(-(tp-thred)^2/(vp^2)))                     
        dp = min(dp1*(AT[i,ceil(Int,t/15)]>thred)+dp2*(AT[i,ceil(Int,t/15)]<=thred),1)
        da =  min(abs(1-mua*exp(-(ta-T[i,floor(Int,t)])^2/(va^2))),1)
        un = [T[i,floor(Int,t)];R[i,floor(Int,t)]]
        NN1 = abs(re(p[1:panu])(un)[1])
        b = 4+16*NN1       
        du[i*2-1] = b*u[i*2]-dp*u[i*2-1]-mu*u[i*2-1]
        du[i*2] = mu*ef*u[i*2-1]-da*u[i*2]
    end
end
u0 = repeat(Float64[1000000,0],city);
tspan = (1.0f0, 1800.0f0)
datasize = 1800;
t = range(tspan[1],tspan[2],length=datasize);
prob = ODEProblem(Wen, u0, tspan, p3);
prediction = concrete_solve(prob,TRBDF2(),u0,p3,saveat=t);
prediction = prediction[:,361:end];
ID2 = [collect(Int64,35:40);collect(Int64,59:64);collect(Int64,83:88)];
aa = Array{Float64}(undef, city, 0)
for i = 1:96
    aa = [aa mean(prediction[2:2:end,(i-1)*15+1:i*15],dims=2)]
end
myresult = zeros((city,96))
maxa = maximum(aa[:,ID2],dims = 2)./maximum(AD[:,ID2],dims = 2)
myresult = aa./maxa;
color1 = RGB(179/255,70/255,138/255);
color2 = RGB(228/255,192/255,214/255);
color3 = RGB(164/255,136/255,186/255);
plot_array = Any[]
color1 = RGB(160/255,39/255,133/255);
color2 = RGB(224/255,204/255,229/255);
color3 = RGB(80/255,27/255,138/255);
tt = collect(Float64,1:15:1440)
ID = [collect(Int64,7:20);collect(Int64,31:43);collect(Int64,55:68);collect(Int64,79:93)];
tt2 = (ID.-1).*15 .+ 1;
for i = 1:9
    condition = (AT[i,25:end] .< 21)
    c = findall(x->x==1,condition)
    c1 = (c.-1).*15 .+ 1;
    c2 =  c.*15 .+1;
    p = scatter(tt2,AD[i,ID],alpha=1.2,shape=:cross,markercolor=color3,markersize=4, markerstrokewidth = 1.2,)
    p = vspan!(p,[c1;;c2]', color =color2, alpha =0.5,labels = false)
    p = plot!(tt,myresult[i, :],lw=3,color=color1,framestyle=:box,yaxis="Adult",yguidefont = (12,"Times"))
    push!(plot_array,p)
end
ID3 = [collect(Int64,7:20);collect(Int64,31:40);collect(Int64,42:43);collect(Int64,55:68);collect(Int64,79:92)];
tt3 = (ID3.-1).*15 .+ 1;
color1 = RGB(177/255,49/255,51/255);
color2 = RGB(255/255,174/255,176/255);
color3 = RGB(156/255,41/255,41/255);
for i = 10:12
    condition = (AT[i,25:end] .< 21)
    c = findall(x->x==1,condition)
    c1 = (c.-1).*15 .+ 1;
    c2 =  c.*15 .+1;
    p = scatter(tt3,AD[i,ID3],alpha=1.2,shape=:cross,markercolor=color3,markersize=4, markerstrokewidth = 1.2,)
    p = vspan!(p,[c1;;c2]', color =color2, alpha =0.5,labels = false)
    p = plot!(tt,myresult[i, :],lw=3,color=color1,framestyle=:box,yaxis="Adult",yguidefont = (12,"Times"))
    push!(plot_array,p)
end
pp1 = plot(plot_array...,size=(1200,520),layout=(4,3),grid=false,dpi=800,legend =false,title=["(a) Shenzhen" "(b) Yangjiang" "(c) Guangzhou" "(d) Shantou" "(e) Shanwei" "(f) Heyuan" "(g) Meizhou" "(h) Zhaoqing" "(I) Shaoguan" "(J) Zhanjiang" "(K) Zhuhai" "(L) Huizhou"],titlefont = (12 ,"times"),left_margin =5mm,bottom_margin=7mm)
xticks = [1,166,346,526,706,886,1066,1246,1426] 
xticks_label = ["16.01","16.06","16.12","17.06","17.12","18.06","18.12","19.06","19.12"]
xticks!(xticks,xticks_label)
xlabel!("2016.01.01-2019.12.31",xguidefont = (12,"Times"))

color1 = RGB(160/255,39/255,133/255);
TT = collect(Float64,15:0.1:35)
a = zeros((6,length(TT)));
RR = [0 20 60 100 150 200];
RR2 = ["R=0mm" "R=20mm" "R=60mm" "R=100mm" "R=150mm" "R=200mm"]
for j = 1:6
    rain = RR[j]
    for i = 1:length(TT)
      a[j,i] = abs(ann([TT[i],rain])[1])*16+4
    end
end
pTA = plot(TT,a',layout = (2,3),size=(900,400),lw=2,color=color1,framestyle=:box,dpi=800,label=RR2,xlabel="Temperature(°C)",margin=0mm, xguidefont = (10,"Times"),ylabel="Oviposition",yguidefont = (10,"Times"),legend =:topleft,legendfont=(7,"Times"))
TT = collect(Float64,15:0.1:35)
a = zeros((17,length(TT)));
RR = [0 5 10 15 20 25 30 35 40 60 80 100 120 140 160 180 200];
RR2 = ["R=0mm" "R=5mm" "R=10mm" "R=15mm" "R=20mm" "R=25mm" "R=30mm" "R=35mm" "R=40mm" "R=60mm" "R=80mm" "R=100mm" "R=120mm" "R=140mm" "R=160mm" "R=180mm" "R=200mm"]
for j = 1:17
    rain = RR[j]
    for i = 1:length(TT)
      a[j,i] = abs(ann([TT[i],rain])[1])*16+4
    end
end
pTA2 = plot(TT,a',size=(300,400),framestyle=:box,label=RR2,lw=2,xlabel="Temperature(°C)", xguidefont = (10,"Times"),ylabel="Oviposition",yguidefont = (10,"Times"),legend =:topleft,legendfont=(7,"Times"))
pTA3 = plot(pTA,pTA2,layout = grid(1, 2, widths=[0.65,0.35]),grid=false,dpi=800,left_margin =5mm,bottom_margin=5mm)



color1 = RGB(160/255,39/255,133/255);
RR = collect(Float64,0:0.5:200)
b = zeros((6,length(RR)));
Tempature = [22 24 26 28 30 32];
Tempature2 = ["T=22°C" "T=24°C" "T=26°C" "T=28°C" "T=30°C" "T=32°C"];
for j = 1:6
    tempature = Tempature[j]
    for i = 1:length(RR)
      b[j,i] = abs(ann([tempature,RR[i]])[1])*16+4
    end
end
pRA = plot(RR,b',layout = (2,3),size=(900,400),lw=2,color=color1,framestyle=:box,dpi=800,label = Tempature2,xlabel="Rrecipitation(mm)", xguidefont = (10,"Times"),ylabel="Oviposition",yguidefont = (10,"Times"),legend =:topright,legendfont = (7,"Times"))
RR = collect(Float64,1:0.1:200);
b = zeros((10,length(RR)));
Tempature = [16 18 20 22 24 26 28 30 32 34];
Tempature2 = ["T=16°C" "T=18°C" "T=20°C" "T=22°C" "T=24°C" "T=26°C" "T=28°C" "T=30°C" "T=32°C" "T=34°C"];
for j = 1:10
    tempature = Tempature[j]
    for i = 1:length(RR)
      b[j,i] = abs(ann([tempature,RR[i]])[1])*16+4
    end
end
pRA2 = plot(RR,b',size=(300,400),framestyle=:box,dpi=500,lw=2,label = Tempature2,xlabel="Rrecipitation(mm)", xguidefont = (10,"Times"),ylabel="Oviposition", yguidefont = (10,"Times"),legend =:topright,legendfont = (7,"Times"))
pRA3 = plot(pRA,pRA2,layout = grid(1, 2, widths=[0.65,0.35]),grid=false,dpi=800,left_margin =3mm,bottom_margin=4mm)
