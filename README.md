# My São Paulo Diorama

Using Lidar data from GeoSampa to build little dioramas from São Paulo.
It uses LidR, Terra and rayshader.

This is mostly an excuse to learn R and rayshader.
Not much documentation is available on how to download data from GeoSampa, might create a package for easly accessing Lidar data.

Some fun results.

MASP Museum in São Paulo. Also used tree detection from lidar data and rayrender to render 3d trees on top of the original one.
![](https://github.com/fmammoli/my-sp-diorama/blob/df7e5c24efde23332632ab0d9b7cb5b1578a36c9/tests/testthat/output_label_trees4.gif)

Some buildings and trees.
![](https://github.com/fmammoli/my-sp-diorama/blob/df7e5c24efde23332632ab0d9b7cb5b1578a36c9/tests/testthat/output_label_trees3.gif)

Just the DEM values in 3d, looks cool.
![](https://github.com/fmammoli/my-sp-diorama/blob/df7e5c24efde23332632ab0d9b7cb5b1578a36c9/tests/testthat/output.gif)

Hight-res render using rayshader raytracing, it takes way too long to render on my notebook.
![](https://github.com/fmammoli/my-sp-diorama/blob/df7e5c24efde23332632ab0d9b7cb5b1578a36c9/tests/testthat/output.png)
