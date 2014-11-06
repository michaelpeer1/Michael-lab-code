a=xff('C:\temp\RoSc_gradients\Person\Linear_correlation\person.vmp');
aa=a.Map.VMPData;

a.Map.VMPData = aa.*(aa<=1 & aa>0);
a.SaveAs('map1.vmp');
a.Map.VMPData = (aa-1).*(aa<=2 & aa>1);
a.SaveAs('map2.vmp');
a.Map.VMPData = (aa-2).*(aa<=3 & aa>2);
a.SaveAs('map3.vmp');
a.Map.VMPData = (aa-3).*(aa<=4 & aa>3);
a.SaveAs('map4.vmp');
a.Map.VMPData = (aa-4).*(aa<=5 & aa>4);
a.SaveAs('map5.vmp');
a.Map.VMPData = (aa-5).*(aa<=6 & aa>5);
a.SaveAs('map6.vmp');
a.Map.VMPData = (aa-6).*(aa>6);
a.SaveAs('map7.vmp');


a=xff('C:\temp\RoSc_gradients\Place_new\Linear_correlation\place.vmp');
aa=a.Map.VMPData;
cd('C:\temp\RoSc_gradients\Place_new\Linear_correlation\');

a.Map.VMPData = aa.*(aa<=1 & aa>0);
a.SaveAs('map1.vmp');
a.Map.VMPData = (aa-1).*(aa<=2 & aa>1);
a.SaveAs('map2.vmp');
a.Map.VMPData = (aa-2).*(aa<=3 & aa>2);
a.SaveAs('map3.vmp');
a.Map.VMPData = (aa-3).*(aa<=4 & aa>3);
a.SaveAs('map4.vmp');
a.Map.VMPData = (aa-4).*(aa<=5 & aa>4);
a.SaveAs('map5.vmp');
a.Map.VMPData = (aa-5).*(aa<=6 & aa>5);
a.SaveAs('map6.vmp');
a.Map.VMPData = (aa-6).*(aa>6);
a.SaveAs('map7.vmp');


a=xff('C:\temp\RoSc_gradients\time\Linear_correlation\time.vmp');
aa=a.Map.VMPData;
cd('C:\temp\RoSc_gradients\time\Linear_correlation\');

a.Map.VMPData = aa.*(aa<=1 & aa>0);
a.SaveAs('map1.vmp');
a.Map.VMPData = (aa-1).*(aa<=2 & aa>1);
a.SaveAs('map2.vmp');
a.Map.VMPData = (aa-2).*(aa<=3 & aa>2);
a.SaveAs('map3.vmp');
a.Map.VMPData = (aa-3).*(aa<=4 & aa>3);
a.SaveAs('map4.vmp');
a.Map.VMPData = (aa-4).*(aa<=5 & aa>4);
a.SaveAs('map5.vmp');
a.Map.VMPData = (aa-5).*(aa<=6 & aa>5);
a.SaveAs('map6.vmp');
a.Map.VMPData = (aa-6).*(aa>6);
a.SaveAs('map7.vmp');

