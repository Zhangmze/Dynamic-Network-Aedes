# -*- coding: utf-8 -*-
from pyecharts.render import make_snapshot
from pyecharts.charts import Map  
from pyecharts import options as opts
from pyecharts.charts import Grid, Scatter
import random
from snapshot_selenium import snapshot
from pyecharts.globals import ThemeType
#prov_city = ['shenzhen', 'yangjiang', 'guangzhou', 'shantou','shanwei','heyuan','meizhou','zhaoqing','shaoguan']
prov_city = ["广州市","深圳市","珠海市","汕头市","佛山市","韶关市","河源市","梅州市","惠州市","汕尾市","东莞市","中山市","江门市","阳江市","湛江市","茂名市","肇庆市","清远市","潮州市","揭阳市","云浮市"]
MOI = [561.783,840.9828,641.5411,772.875,829.5855,1128.851,863.3982,1040.0526,663.2094,363.1,525,1030.15,561.7,520.325,495.3,761.3856,646.342,538.9164,417.45,847.3,598,627.925]
temp = [30.1,30,30,29.8,30.6,28.6,26.6,28.8,29.7,30.2,29.8,22.2,30.6,30.9,31.0,30.9,30.0,30.0,29.0,29.8,27.4];
rain = [1217.3,410.9,720.3,558.4,849.5,565.2,491.6,856.2,534.7,190.5,871.4,913.9,509.1,505.5,364.2,391.5,611.4,1341.7,631.8,279.3,501.6];
data = MOI
data_prov_city = [(i, j) for i,j in zip(prov_city,data)]
worldmap=Map(init_opts=opts.InitOpts(width="400px",height="400px",bg_color='white'))
worldmap.add("",
         data_prov_city,
         "广东",is_map_symbol_show=True)
worldmap.set_series_opts(label_opts=opts.LabelOpts(is_show=False),showLegendSymbol=False)
worldmap.set_global_opts(
        legend_opts=opts.LegendOpts(is_show=False),
        visualmap_opts=opts.VisualMapOpts(
            min_=300,
            max_=1200,
            range_color=["rgb(197,197,224)","rgb(156,152,199)","rgb(121,111,179)","rgb(091,053,149)","rgb(064,003,126)"],
            #range_color=["rgb(243,217,190)","rgb(236,194,155)","rgb(239,145,099)","rgb(205,068,050)","rgb(097,030,030)"],
            #range_color=["rgb(233,241,244)","rgb(182,215,232)","rgb(109,173,209)","rgb(049,124,183)","rgb(016,070,128)"],
            is_piecewise=False,
            range_opacity = None,
            is_show = True,
            pieces = None,
            orient='vertical',
            pos_right='12%',
            pos_bottom = '10%',
            item_width = 15,
            item_height = 100
        )
    )
make_snapshot(snapshot,worldmap.render(),"./figure/GuangdongMOI.png",pixel_ratio=5.0)
#make_snapshot(snapshot,worldmap.render(),"./figure/GuangdongT.png",pixel_ratio=5.0)
#make_snapshot(snapshot,worldmap.render(),"./figure/GuangdongR.png",pixel_ratio=5.0)
