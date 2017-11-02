<!doctype html>
<html>
<head>
<!--<link href='/html/sn-static/static/sumap/examples/css/bootstrap.min.css' rel='stylesheet' />
<link href='/html/sn-static/static/sumap/examples/css/bootstrap-responsive.min.css' rel='stylesheet' />-->
<#include "/template/sn_head.ftl">

<script src='/html/sn-static/static/sumap/libs/SuperMap.Include.js'></script>
<script type="text/javascript" src="/html/sn-static/static/js/jquery.base64.js"></script>
<script type="text/javascript" src="/html/sn-static/static/js/tkmethod.js"></script>
<script type="text/javascript">   
 //加密方法。没有过滤首尾空格，即没有trim.    
//加密可以加密N次，对应解密N次就可以获取明文    
 function encodeBase64(mingwen,times){    
    var code="";    
    var num=1;    
    if(typeof times=='undefined'||times==null||times==""){    
       num=1;    
    }else{    
       var vt=times+"";    
       num=parseInt(vt);    
    }    
    if(typeof mingwen=='undefined'||mingwen==null||mingwen==""){    
    }else{    
        $.base64.utf8encode = true;    
        code=mingwen;    
        for(var i=0;i<num;i++){    
           code=$.base64.btoa(code);    
        }    
    }    
    return code;    
};   
        $(function () {  
		$("#pic_list_1").hide();
            $.ajax({    //初始化选择框
                type: "post",  
                contentType: "application/json",  
                url: "ajax/findAllCounty",  
                data: "{}",  
                success: function (result) {  
                	if(result.msg=='success'){
	                    var stroption = '';  
	                    for (var i = 0; i < result.data.length; i++) {  
	                        stroption += '<option value=' + result.data[i].code + '>';  
	                        stroption += result.data[i].mc;  
	                        stroption += '</option>';  
	                    }  
	                    $('#bj-region').append(stroption);
			    setTimeout(function(){$('#bj-region').find("option[value='110113']").attr("selected",true).trigger("change");},50); 
                	}else{
                		console.log("无结果集");
                	}
                }  
            })  
 
            $('#bj-region').change(function () {  //选择区县进行异步查询其下的乡镇
              var qx =encodeBase64($(this).val());  
	                $('#bj-town option:gt(0)').remove();  
	                $('#villages option:gt(0)').remove();  
	                $.ajax({  
	                    type: "post",  
	                    contentType: "application/json",  
	                    url: "ajax/findTownByQxCode?qxCode="+qx,  
	                    success: function (result) {  
	                    	if(result.msg=='success'){
		                        var strqx = '';  
		                        for (var i = 0; i < result.data.length; i++) {  
		                            strqx += '<option value=' + result.data[i].code + '>';  
		                            strqx += result.data[i].mc;  
		                            strqx += '</option>';  
		                        }  
		                        $('#bj-town').append(strqx);
					setTimeout(function(){$('#bj-town').find("option[value='110113116']").attr("selected",true);$('#bj-town').trigger("change");},50); 
	                    	}else{
	                    		
	                    	}
	                    }  
               		 });  
            })  
  
            $('#bj-town').change(function () { //选择乡镇进行其下的村子查询
            	 var xz =encodeBase64($(this).val());
            	 
            	if(xz==null){
            		return false;
            	}
                $('#villages option:gt(0)').remove();  
                $.ajax({  
                    type: "post",  
                    contentType: "application/json",  
                    url: "ajax/findVillageByXzCode?xzCode="+xz,  
                    success: function (result) {
                    	if(result.msg=='success'){
	                        var strvillage = '';  
	                        for (var i = 0; i < result.data.length; i++) {  
	                            strvillage += '<option value=' + result.data[i].code + '>';  
	                            strvillage += result.data[i].mc;  
	                            strvillage += '</option>';  
	                        }  
	                        $('#villages').append(strvillage);  
				setTimeout(function(){$('#villages').find("option[value='110113116202']").attr("selected",true);$('#villages').trigger("change"); },50); 
                    	}else{}
                    }  
                }) ; 
            })
	    //init('110113116202',"北郎中村");
	    initMap("北郎中村");
	    initGuiHua("北郎中村");
        })  
    </script> 
    <script type="text/javascript">
	var villageCode="";
	var topicVillageinfoCropYear="";
	function ShowDialog(url,title) {  //活动窗口，传入url以小窗口展示
		
		 $.ajax({url:url,
		 type:'GET',
		 datatype:'html',
		success:function(html){
			var obj={
				   type:"none",
				   title:title,
				   content:html,
				   area:["800px","500px"]
			   };
			   method.msg_layer(obj);
			   
		},error:function(e){
			console.log(e);
		}

		 })
		 
		
	}
	function init(code,name){ //1、初始化页面 2、选择框村情查询（整个页面的查询）
		villageCode=code || $("#villages").val();
		var villageName = name||$("#villages option:selected").html();
		$(".alter-btn").html(villageName);
		//地图定位
		queryBySQL(villageName);
		//图则
		initGuiHua(villageName);
		$("#mslyc").hide();
		$("#xclycXq").hide();
		selectSearch(villageCode);
		selectCropSearch(villageCode);
		selectTalentsSearch(villageCode);	
			
	}
	function selectSearch(villageCode){  //村情查询（整个页面）
	if(villageCode==null){
			return false;
		}
		tipItems='${tipItems}';
		items=tipItems.split(",");
		for(var i=0;i<items.length;i++){
			 findItemCountInVillage(villageCode,items[i],items[i]); 
		}
		findVillageInfoByCode(villageCode);
				

	}
	function selectCropSearch(villageCode){    //查询各种作物的数量   villageCode  村子编码
	    topicVillageinfoCropYear='${topicVillageinfoCropYear}';
	    findCropCount(villageCode,"shucai","shucai");
		findCropCount(villageCode,"liangjing","liangjing");	
        findCropCount(villageCode,"guopinzuowu","guopinzuowu");
		findCropCount(villageCode,"qitazuowu","qitazuowu");	
	}
	
	function selectTalentsSearch(villageCode)	{ //实用人才数量
	  findTalentsCount(villageCode,"Talents");
	}
	
	
	
	function findItemCountInVillage(villageCode,tipItem,itemId) {  //查询村中的各个项目的数量. villageCode:村子编码   tipItem:项目名  itemId:项目在页面的id
		$.ajax({
			type : "POST",
			dataType : "json",
			data:"villageCode=" + encodeBase64(villageCode) + "&tipItem=" + encodeBase64(tipItem.replace('/',',')),
			url : "ajax/findItemCountInVillage",
			success : function(data) {
				if(data.msg=="success"){
					$("."+itemId.replace('/','')).text(data.data.value);
					if(data.data.key=="XclyLyc"){
						if(data.data.value==1){
							//showValliage(false);
							$("#mslyc").show();
							$("#xclycXq").show();

						}
						else{
							//showValliage(true);		
						}
					}
				}
					
					
				},
			   error :function(e){
				   console.log("请求错误");
			   }
			});
	}
	function findTalentsCount(villageCode,itemId) {  //查询村中的实用人才的数量.  itemId:项目在页面的id
	   $.ajax({
			type : "POST",
			dataType : "json",
			data:"villageCode=" + encodeBase64(villageCode),
			url : "ajax/findTalentsCount",
			success : function(data) {
				if(data.msg=="success"){
					$("."+itemId).text(data.data.value);
					}
			},
		   error :function(e){
			   console.log("请求错误");
		   }
		});
	}
	function findCropCount(villageCode,cropType,itemId) {  //查询村中的各个项目的数量.  itemId:项目在页面的id
		$.ajax({
			type : "POST",
			dataType : "json",
			data:"villageCode=" + encodeBase64(villageCode) + "&cropType=" +encodeBase64(cropType)+ "&nf=" +encodeBase64(topicVillageinfoCropYear) ,
			url : "ajax/findCropCount",
			success : function(data) {
				if(data.msg=="success"){
					$("."+itemId).text(data.data.value);
					}
			},
		   error :function(e){
			   console.log("请求错误");
		   }
		});
	}
	function findItemInfoInVillage(tipItem,title) {  //查询村中的项目详情   tipItem：项目名
		var url="view/findItemInfoInVillage?villageCode="+encodeBase64(villageCode) +"&tipItem="+encodeBase64(tipItem);
		title="结果";
		ShowDialog(url,title);
	}
	
	function findCropInfo(cropType,title) {  //查询村中的作物详情   cropType：作物类型   
		var url="view/findCropInfo?villageCode="+encodeBase64(villageCode)+"&cropType="+encodeBase64(cropType)+"&nf="+encodeBase64(topicVillageinfoCropYear);
		title="结果";
		ShowDialog(url,title);
		
	}
	function findTalentsInfo(title) {  //查询村中的作物详情   cropType：作物类型   
		var url="view/findTalentsInfo?villageCode="+encodeBase64(villageCode);
		title="结果";
		ShowDialog(url,title);
		
	}
	
	function findVillageInfoByCode(villageCode) {  //通过村子编码查询村子详情
		$.ajax({
			type : "POST",
			dataType : "json",
			data:"villageCode=" + encodeBase64(villageCode),
			url : "findVillageInfoByCode",
			success : function(data) {
				if(data.msg=="success"){
					$(".villagename").text(data.data.village.szXzC);
					var jianjie = data.data.xclyJj;
					if(jianjie){
						if(jianjie.length>150){
							jianjie = jianjie.substr(0,150)+"...";
						}
					}
					$(".lycJianjie").text(jianjie);
					$("#village_num").text(data.data.village.code);
					$("#region-num").text(data.data.village.szQx);
					$("#area_num").text(data.data.village.mj+"平方千米");
					$("#plant_num").text(data.data.village.plantMj+"亩");
					$("#animal_num").text(data.data.village.animalMj+"亩");
					$("#forest_num").text(data.data.village.result.lyyd_zmj+"亩");
			}
			},
		   error :function(e){
			   console.log("请求错误");
		   }
		});
	}
	
	function findVillageByName() {  //通过村子名模糊查询村子列表
		var villageName=$("input[name='xczMc']").val();
		if($.trim(villageName)==null||villageName==""){
			alert("请输入查询村名");
		}else{
			ShowDialog("view/findVillageByName?villageName="+villageName,"查询结果");
		}
	}
	
	function showValliage(f){
		var valliage = document.getElementById("show_valliage"); 
		if(f){
			valliage.style.paddingTop = "170px";
			valliage.style.background = "url(/html/sn-static/static/image/cuntwo.png)";
			valliage.style.backgroundRepeat = "no-repeat";
			valliage.style.backgroundPosition = "center top 40px";
			 
		}else{
			valliage.style.paddingTop = "0px";
			valliage.style.background = "none";
			
		}
	}

/* 地图服务 start*/
 var map, local, layer, vectorLayer, features, select, tempLayer , drag, delIndex = 0, editEnable = false,control, queryBounds, markerLayer,drawFeature,layerWorld,
            //设置图层样式
            style = {
                externalGraphic: "/html/sn-static/static/sumap/examples/images/marker.png",
                graphicWidth: 13,
                graphicHeight: 16,
                name: "town"
            },
            styleCity = {
                pointRadius: 10,
                externalGraphic: "/html/sn-static/static/sumap/examples/images/markerbig.png",
                name: "city"
            },
            styleCaptial = {
                pointRadius: 15,
                externalGraphic: "/html/sn-static/static/sumap/examples/images/markerflag.png",
                name: "captial"
            },
			styleBound = {
                strokeColor: "#304DBE",
                strokeWidth: 1,
                pointerEvents: "visiblePainted",
                fillColor: "#304DBE",
                fillOpacity: 0.3
            },transformControl,
            host ="http://172.24.61.42:8090";// document.location.toString().match(/file:\/\//)?"http://localhost:8090":'http://' + document.location.host,
            //host="http://10.0.64.67:8090";
           // url1=host+"/iserver/services/map-China/rest/maps/sheNongCQ";
	    url1=host+"/iserver/services/map-Shenong/rest/maps/sheNongCQ";
            function initMap(name){
                /*
                 * 不支持canvas的浏览器不能运行该范例
                 * android 设备也不能运行该范例*/
                var broz = SuperMap.Util.getBrowser();

                if(!document.createElement('canvas').getContext) {
                    alert("地图服务:"+'您的浏览器不支持 canvas，请升级');
                    return;
                } else if (broz.device === 'android') {
                    alert("地图服务:"+'您的设备不支持高性能渲染，请使用pc或其他设备');
                    return;
                }

                //加载map控件
                map = new SuperMap.Map("map",{controls: [
                    new SuperMap.Control.LayerSwitcher(),
                    new SuperMap.Control.ScaleLine(),
                    new SuperMap.Control.Zoom(),
                    new SuperMap.Control.Navigation({
                        dragPanOptions: {
                            enableKinetic: true 
                        }
                    })], units: "m"
                });
                //初始化图层
                layerWorld = new SuperMap.Layer.TiledDynamicRESTLayer("sheNongCQ", url1, {transparent: true, cacheEnabled: true}, {maxResolution:"auto"});
                layerWorld.events.on({"layerInitialized":addLayer});
                //初始化Vector图层
                vectorLayer = new SuperMap.Layer.Vector("Vector Layer", {renderers: ["Canvas2"]});
				//鹰眼控件
				overviewmap = new SuperMap.Control.OverviewMap();
				//属性minRectSize：鹰眼范围矩形边框的最小的宽度和高度。默认为8pixels
				overviewmap.minRectSize = 20;
				//layerWorld = new SuperMap.Layer.TiledDynamicRESTLayer("ZTshenong", url1);     //获取图层服务地址
				layerWorld.events.on({"layerInitialized": addLayer});

				//给在vector图层上所选择的要素初始化
                select = new SuperMap.Control.SelectFeature(vectorLayer, {onSelect: onFeatureSelect, onUnselect: onFeatureUnselect, repeat:true});
                map.addControl(select);
		//queryBySQL(name);	

               
            }
			
            //添加图层
            function addLayer() {
                map.addLayers([vectorLayer,layerWorld]);
                map.setCenter(new SuperMap.LonLat(524221.11, 337620.34), 2);        
				//map.addControl(new SuperMap.Control.MousePosition()) ;
				map.addControl(overviewmap);
            }
            //要素被选中时调用此函数
            function onFeatureSelect(feature) {
                if(editEnable) {
                    editSelectedFeatures();
                } else {
                    selectedFeature = feature;
                    //被点选的feature第二次被选中的时候popup无需重新构建，直接显示即可
                    if(feature.popup){
                        feature.popup.show();
                        return;
                    }
					
                    var contentHTML = "<div style='font-size:.8em; opacity: 0.8; overflow-y:hidden;'>" +
                            "<span style='font-weight: bold; font-size: 18px;'>详细信息</span><br>";
			 contentHTML += "名称：" + feature.attributes["MC"] + "<br>";	
			contentHTML += "ID：" + feature.attributes["ID"] + "<br>";
                    //初始化一个弹出窗口，当某个地图要素被选中时会弹出此窗口，用来显示选中地图要素的属性信息
                    popup = new SuperMap.Popup.FramedCloud("chicken",
                            feature.geometry.getBounds().getCenterLonLat(),
                            null,
                            contentHTML,
                            null,
                            true,
                            null,
                            true);
                    feature.popup = popup;
                    map.addPopup(popup);
					var a = feature.attributes["SmX"];
					var b = feature.attributes["SmY"];
					map.setCenter(new SuperMap.LonLat(a,b),8); 
                }
            }
				
         
            //关闭弹出窗口
            function onPopupClose(evt) {
            }
            //清除要素时调用此函数
            function onFeatureUnselect(feature) {
                map.removePopup(feature.popup);
                feature.popup.destroy();
                feature.popup = null;
            }
			 function drawGeometry() {
					//先清除上次的显示结果
					clearFeatures();

					drawFeature.activate();
			}
			
            //SQL查询
            function queryBySQL(Pname) {
                vectorLayer.removeAllFeatures();
                delIndex =0;
                //查询中国的全部省会。
                var queryParamCapital, queryBySQLParamsCapital, queryBySQLServiceCapital,param,params,type;
				//param = document.getElementById("text1").value;
				type = "ST_VILLAGE_DIA_PT@221";
				params = "ID > 0";
				if(Pname.length != 0){
					type = "ST_VILLAGE_DIA_PT@221";
					params = "MC='"+Pname+"'";		
						
				}
			
			
			
                queryParamCapital = new SuperMap.REST.FilterParameter({
                    name: type,
					attributeFilter:params 
				}),
                    //初始化sql查询参数
                        queryBySQLParamsCapital = new SuperMap.REST.QueryBySQLParameters({
                            queryParams: [queryParamCapital]
                        }),
                    //SQL查询服务
                        queryBySQLServiceCapital = new SuperMap.REST.QueryBySQLService(url1, {
                            eventListeners: {"processCompleted": processCompletedCapital, "processFailed": processFailedCapital}});
                queryBySQLServiceCapital.processAsync(queryBySQLParamsCapital);
				//$("#text1").val("");
            }

            //SQL查询(省会)成功时触发此事件
            function processCompletedCapital(queryEventArgs) { 
                var i, j, feature,
                        result = queryEventArgs.result;
                features = [];
                if (result && result.recordsets) {
                    for (i=0; i<result.recordsets.length; i++) {
                        if (result.recordsets[i].features) {
                            for (j=0; j<result.recordsets[i].features.length; j++) {
                                feature = result.recordsets[i].features[j];
                                feature.style = styleCaptial;
                                features.push(feature);
				var a = feature.attributes["SmX"];
				var b = feature.attributes["SmY"];
				//alert("地图服务:" + a +":"+b);
				map.setCenter(new SuperMap.LonLat(a,b),9); 
                            }
                        }
                    }
                }
			
		
				
                vectorLayer.addFeatures(features);
                select.activate();
				
            }

            //SQL查询(省会)失败时出发的事件
            function processFailedCapital(e) {
                alert("地图服务:"+e.error.errorMsg);
            }
			 
            function processFailed(e) {
                alert("地图服务:"+e.error.errorMsg);
            }
			var infowin = null;
            //清除全部要素
            function clearFeatures(){
                if(vectorLayer.selectedFeatures.length > 0) {
                    map.removePopup(vectorLayer.selectedFeatures[0].popup);
                }
				map.setCenter(new SuperMap.LonLat(524221.11, 337620.34), 2);        
                vectorLayer.removeAllFeatures();
                markerLayer.clearMarkers();
                closeInfoWin();
            }
			function closeInfoWin(){
                if(infowin){
                    try{
                        infowin.hide();
                        infowin.destroy();
                    }
                    catch(e){}
                }
            }
/* 地图服务 end*/
/* 规划图则start*/
	function initGuiHua(cname){
		
		$.ajax({url:"./czghpic/byname",
			data:{name:cname},
			success:function(res){
				if(res.status==1){
					var list = res.data;
					if(list && list.length>0){
						$("#pic_list_parent").html('');
						$("#downtuze").remove();
						var tuzeparent = '<div id="pic_list_1">'
							+'<a class="prev" href="javascript:void(0)"><img src="/html/sn-static/static/image/prev.png" width="35" height="54"></a>'
							+'<a class="next" href="javascript:void(0)"><img src="/html/sn-static/static/image/next.png" width="35" height="54"></a>'
							+'<div class="box box1">'
							+'<ul class="list clearfix" id="tuze">'
							+'</ul>'
							+'</div>'
							+'</div>'
							+'<div id="downtuze"></div>';
						$("#pic_list_parent").append(tuzeparent);
						var $tuze = $('#tuze');
						var $downtuze = $('#downtuze');
						//$("#pic_list_1").show();
						var items = '';
						for(var i=0;i<list.length;i++){
							var item = list[i];
							if(item.typeId=='1'){
								$tuze.append('<li><a href="javascript:void(0);"><img src="/resource/countryPic/02/'+item.url+'" width="180" height="115"><p>'+item.fileName.replace(".jpg",'')+'</p></a></li>');		
							}else if(item.typeId=='2'){
								$downtuze.append('<div><a href="/resource/countryPic/02/'+item.url+'">'+item.fileName+'</a></div>');
							}
						}
						$tuze.find("li").click(function(){
							/*var src = $(this).find('img').attr('src');
							src = src.replace("/02/",'/Layout/');
							$("#imgLocation").find("li").find('img').attr('src',src);
							$("#imgLocation").find("li").fadeIn().siblings().fadeOut(1000);
							$("#imgLocation").find("li").find("span").click(function(){
								$("#imgLocation").find("li").hide();										
							});*/
							var src = $(this).find('img').attr('src');
							var title = $(this).find('p').html();
							src = src.replace("/02/",'/Layout/');
							method.msg_layer({
								  type:'none',
								  title: title,
								  area: ['800px','550px'],
								  content: '<img style="width: 100%;height: 100%;" src="'+src+'">'
								});
						});
						$("#pic_list_1").cxScroll();
						
					}else{
						
						console.log("没有村庄规划图则");
						$("#pic_list_1").hide();
					}

				}else{
					console.log("规划图片加载失败！");
				}
			}});
	}


/* 规划图则end*/

</script>
	<!--[if lt IE 10]> 
	<style>
		.head-bottom{background:url(/html/sn-static/static/image/navbanner.png) no-repeat;}
	</style>
	<![endif]-->
</head>

<body>
<#include "/template/sn_header.ftl">
    <div class="wrapper" id="wrapper" style="background:#ebeced;">
    	<div class="container" style="background:#fff;">
        	<div class="row mgt15" style="margin-bottom:15px;">
            	<div class="col-md-12">
                    <ul class="resource-infoList">

                        <li>
						<label>
                            <span>行政区划：</span>
                            <select name="bj-region" id="bj-region" class="alter-sel" >
							<option value='' disabled="disabled">--请选择--</option>
							</select>
                        </label>	
                        </li>
                        <li>
						<label>
                            <span>乡镇：</span>
									<select name="bj-town" id="bj-town" class="alter-sel">
									<option value='' disabled="disabled" >--请选择--</option>
									</select>
								</label>
                        </li>
                        <li>
                            <label>
                                <span>行政村：</span>
                                <select name="bj-villages" id="villages" class="alter-sel" onchange="init();">
                                    <option value ="" disabled="disabled">--请选择--</option>
                                    
                                </select>
                            </label>	
                        </li>
                        <li>
                            <label>
								<input type="text" name="xczMc" value="" placeholder="关键词搜索"  style="padding:2px; font-size:12px;">
								<button type="button" value="" onclick="findVillageByName();" class="b-btn fontSize12">搜索</button>
                            </label>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="row mgt15">
            	<div class="show_location">
			<div id="map" style="width:100%;height:355px"></div>
			
                        <ul id="imgLocation"><li><img src=""><span></span></li></ul>
                	<!--<img src="/html/sn-static/static/image/map1.png" width="100%" height="355">-->
			<div class="hot-subject" style="padding-top:20px;" id='pic_list_parent'>
                    	
			</div>
			
                </div>
            </div>
	    
	    
            <div class="row">
            	<div class="col-md-12">
                	<p><span class="btn alter-btn">北郎中村</span></p>
                    <p class="lycJianjie"></p>
                </div>
            </div>
            <div class="row mgt15">
            	<div class="show_data_info clearfix">
                	<!--左边-->
                    <div class="col-md-4 col-lg-4">
                    	<div class="resource-left">    
                        	<!--基本信息-->
                            <div class="show_base_info">
                                <div class="resource-con show_base_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit1">基本情况</span></div>
                                        <ul>
                                            <li>
                                            <span>行政村编码:</span>
                                            <span class="add-num" id="village_num">暂无信息</span>
                                        </li>
                                        <li>
                                            <span>所属区县:</span>
                                            <span class="add-num" id="region-num">暂无信息</span>
                                        </li>
                                        <li>
                                            <span>总面积:</span>
                                            <span class="add-num" id="area_num">暂无信息</span>
                                        </li>
                                        <li>
                                            <span>种植面积:</span>
                                            <span class="add-num" id="plant_num">暂无信息</span>
                                        </li>
                                         <li>
                                            <span>畜牧面积:</span>
                                            <span class="add-num" id="animal_num">暂无信息</span>
                                        </li>
                                        <li>
                                            <span>林业面积:</span>
                                            <span class="add-num" id="forest_num">暂无信息</span>
                                        </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>            	
                        	<!--休闲旅游-->
                            <div class="show_tour">
                            	<div class="resource-con show_tour_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit2">休闲旅游</span></div>
										<ul>
											<li>
											<a  href="javascript:void(0);" title="点击查看详情"   onclick="findItemInfoInVillage('XclyLyh');" data-toggle="modal" data-target="#myModal14"  class="cqLinks">
                                            <span>民俗旅游户:</span>
                                            <span class="add-num XclyLyh" id="superM2_num" data-toggle="modal" data-target="#myModal14">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
										<a href="javascript:void(0);" title="点击查看详情"   onclick="findItemInfoInVillage('XclyNyYq');" data-toggle="modal"		data-target="#myModal15" class="cqLinks">
                                            <span>休闲农业园区:</span>
                                            <span class="add-num XclyNyYq" id="superM3_num" data-toggle="modal" data-target="#myModal15">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                            
                                        </ul>
                                       
                                    </div>
                                </div>
                            </div>
                        <!--种植生产-->	
                        	<div class="show_plantation">
                            	<div class="resource-con show_plantation_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit3">种植生产</span></div>
                                        <ul>
                                            <li>
						<a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"  onclick="findItemInfoInVillage('SanpinJbxx');" data-toggle="modal" data-target="#myModal1">
                                            <span>种植基地:</span>
                                            <span class="add-num SanpinJbxx" id="garden1_base_num" data-toggle="modal" data-target="#myModal1">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li> <a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"  onclick="findItemInfoInVillage('MpJbxx');" data-toggle="modal" data-target="#myModal1">
                                            <span>苗圃基地:</span>
                                            <span class="add-num MpJbxx" id="garden1_base_num" data-toggle="modal" data-target="#myModal1">0</span>
                                            <span class="un">个</span>
						</a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"   onclick="findItemInfoInVillage('GyJbxx');" data-toggle="modal" data-target="#myModal2">
                                            <span>果园基地:</span>
                                            <span class="add-num GyJbxx" id="garden2_base_num" class="cqLinks" data-toggle="modal" data-target="#myModal2">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"  onclick="findItemInfoInVillage('HhjdJbxx');" data-toggle="modal" data-target="#myModal3">
                                            <span>花卉基地:</span>
                                            <span class="add-num HhjdJbxx" id="garden3_base_num" data-toggle="modal" data-target="#myModal3">0</span>
                                            <span class="un">个</span>
					</a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"   onclick="findItemInfoInVillage('GggyJbxx');" data-toggle="modal" data-target="#myModal4">
                                            <span>观光果园:</span>
                                            <span class="add-num GggyJbxx" id="garden4_base_num" data-toggle="modal" data-target="#myModal4">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"  onclick="findItemInfoInVillage('SnqyJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>涉农企业:</span>
                                            <span class="add-num SnqyJbxx" id="shenong_base_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"  class="cqLinks"  onclick="findItemInfoInVillage('TsNcpJbxx,CmsYcypShier');" data-toggle="modal" data-target="#myModal19">
                                            <span>特色农产品:</span>
                                            <span class="add-num TsNcpJbxxCmsYcypShier" id="shenong_base_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>  
                    <!--中间-->
                   	<div class="col-md-4 col-lg-4">
                    	<div class="resource-left">
                        	<!--农业科技-->
                            <div class="show_farm">
                                    <div class="resource-con show_farm_bg">
                                        <div class="panel-body" style="padding-left:40px;">
                                        	<div style="margin-bottom:10px;"><span class="info_tit info_tit4">农业科技</span></div>
                                           <ul>
                                               <li>
					       <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findTalentsInfo()" data-toggle="modal" data-target="#myModal15">
                                            <span>实用人才:</span>
                                            <span class="add-num Talents" id="superM3_num" data-toggle="modal" data-target="#myModal15">0</span>
                                            <span class="un">人</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('KjsfhJbxx');" data-toggle="modal" data-target="#myModal16">
                                            <span>科技示范户：</span>
                                            <span class="add-num KjsfhJbxx" id="tecnology1_num" data-toggle="modal" data-target="#myModal16">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('KjsfyqJbxx');" data-toggle="modal" data-target="#myModal17">
                                            <span>科技示范园区:</span>
                                            <span class="add-num KjsfyqJbxx" id="tecnology2_num" data-toggle="modal" data-target="#myModal17">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('WlwsdjsJbxx');" data-toggle="modal" data-target="#myModal18">
                                            <span>物联网示范点:</span>
                                            <span class="add-num WlwsdjsJbxx" id="tecnology3_num" data-toggle="modal" data-target="#myModal18">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NyjstgzJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>农业技术推广站:</span>
                                            <span class="add-num NyjstgzJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NykjAnyzJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>爱农驿站:</span>
                                            <span class="add-num NykjAnyzJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NykjYcjyzdJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>远程教育站点:</span>
                                            <span class="add-num NykjYcjyzdJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NykjSzjyJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>数字家园:</span>
                                            <span class="add-num NykjSzjyJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                    <li>
				    <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NykjXtygzzJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>协调员工作站:</span>
                                            <span class="add-num NykjXtygzzJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NjfwzzJbxx');" data-toggle="modal" data-target="#myModal19">
                                            <span>农机服务组织:</span>
                                            <span class="add-num NjfwzzJbxx" id="tecnology4_num" data-toggle="modal" data-target="#myModal19">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
				<!--市场资源-->
                                <div class="show_market">
                                    <div class="resource-con show_market_bg">
                                        <div class="panel-body" style="padding-left:40px;">
                                        	<div style="margin-bottom:10px;"><span class="info_tit info_tit6">市场资源</span></div>
                                            <ul>
                                            <li>
					    <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('CsJbxx');" data-toggle="modal" data-target="#myModal13">
                                            <span>百货超市:</span>
                                            <span class="add-num CsJbxx" id="superM1_num" data-toggle="modal" data-target="#myModal13">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NfscJbxx');" data-toggle="modal" data-target="#myModal14">
                                            <span>农副市场:</span>
                                            <span class="add-num NfscJbxx" id="superM2_num" data-toggle="modal" data-target="#myModal14">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" title="点击查看详情"   onclick="findItemInfoInVillage('JyscJbxx');" data-toggle="modal" data-target="#myModal15">
                                            <span>经营市场:</span>
                                            <span class="add-num JyscJbxx" id="superM3_num" data-toggle="modal" data-target="#myModal15">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        </ul>
                                        </div>
                                    </div>
                                </div>
			<!--农作物信息-->
                            <div class="show_crop">
                            	<div class="resource-con show_crop_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit8">农作物信息</span></div>
                                        <ul>
                                           <li>
					   <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findCropInfo('shucai');" data-toggle="modal" data-target="#myModal6">
                                            <span>蔬菜作物:</span>
                                            <span class="add-num shucai" id="farm_base_num" data-toggle="modal" data-target="#myModal6">0</span>
                                            <span class="un">种</span>
                                            </a>
                                        </li>
						<li>
						<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findCropInfo('liangjing');" data-toggle="modal" data-target="#myModal6">
                                            <span>粮食作物:</span>
                                            <span class="add-num liangjing" id="farm_base_num" data-toggle="modal" data-target="#myModal6">0</span>
                                            <span class="un">种</span>
                                            </a>
                                        </li>
					<li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findCropInfo('guopin');" data-toggle="modal" data-target="#myModal6">
                                            <span>果品作物:</span>
                                            <span class="add-num guopinzuowu" id="farm_base_num" data-toggle="modal" data-target="#myModal6">0</span>
                                            <span class="un">种</span>
                                            </a>
                                        </li>
					<li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findCropInfo('qitazuowu');" data-toggle="modal" data-target="#myModal6">
                                            <span>其他作物:</span>
                                            <span class="add-num qitazuowu" id="farm_base_num" data-toggle="modal" data-target="#myModal6">0</span>
                                            <span class="un">种</span>
                                            </a>
                                        </li>
                                        </ul>
                                    </div>
                                </div>	
                            </div>
                           
                        </div>
                    </div>
                    <!--右边-->
                    <div class="col-md-4 col-lg-4">
                    	<div class="resource-right"> 
                        	<!--畜牧水产-->	
                            <div class="show_livestock">
                            	<div class="resource-con show_livestock_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit7">畜牧水产</span></div>
                                       <ul class="clearfix">
                                            <li>
					    <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('YzcJbxx');" data-toggle="modal" data-target="#myModal7">
                                            <span>养殖场:</span>
                                            <span class="add-num YzcJbxx" id="beast2_num" data-toggle="modal" data-target="#myModal7">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('XqlzcJbxx');" data-toggle="modal" data-target="#myModal7">
                                            <span>畜禽良种场:</span>
                                            <span class="add-num XqlzcJbxx" id="beast2_num" data-toggle="modal" data-target="#myModal7">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('DanjiJbxx');" data-toggle="modal" data-target="#myModal8">
                                            <span>蛋鸡养殖场:</span>
                                            <span class="add-num DanjiJbxx" id="beast2_num" data-toggle="modal" data-target="#myModal8">0</span>
                                            <span class="un">个</span>
                                             </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('RoujiyzJbxx');" data-toggle="modal" data-target="#myModal1">
                                            <span>肉鸡养殖场:</span>
                                            <span class="add-num RoujiyzJbxx" id="beast5_num" data-toggle="modal" data-target="#myModal13">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('NainiuJbxx');" data-toggle="modal" data-target="#myModal9">
                                            <span>奶牛养殖场:</span>
                                            <span class="add-num NainiuJbxx" id="beast3_num" data-toggle="modal" data-target="#myModal9">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('ScyzcJbxx');" data-toggle="modal" data-target="#myModal10">
                                            <span>水产养殖场:</span>
                                            <span class="add-num ScyzcJbxx" id="beast4_num" data-toggle="modal" data-target="#myModal10">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('TzqyJbxx');" data-toggle="modal" data-target="#myModal1">
                                            <span>屠宰企业:</span>
                                            <span class="add-num TzqyJbxx" id="beast5_num" data-toggle="modal" data-target="#myModal1">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('SyjyqyJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>兽药经营企业:</span>
                                            <span class="add-num SyjyqyJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                            
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('Yayzcbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>鸭养殖场:</span>
                                            <span class="add-num Yayzcbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('RouniuyzJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>肉牛养殖场:</span>
                                            <span class="add-num RouniuyzJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                      
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('ShengzhuJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>生猪养殖场:</span>
                                            <span class="add-num ShengzhuJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                           <li>
					   <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('TsyzJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>特色养殖养殖场:</span>
                                            <span class="add-num RouniuyzJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('YangyzJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>羊养殖场:</span>
                                            <span class="add-num YangyzJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('SczsqyyzJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>水产追溯企业:</span>
                                            <span class="add-num SczsqyyzJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                        <li>
					<a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('DwwsfysJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>动物卫生防疫所:</span>
                                            <span class="add-num DwwsfysJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                             </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('DwzldwJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>动物诊疗单位:</span>
                                            <span class="add-num DwzldwJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('SlqyyzJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>饲料企业:</span>
                                            <span class="add-num SlqyyzJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>
                                         <!--<li>
					 <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('XmjgJbxx');" data-toggle="modal" data-target="#myModal12">
                                            <span>畜牧相关机构:</span>
                                            <span class="add-num XmjgJbxx" id="beast6_num" data-toggle="modal" data-target="#myModal12">0</span>
                                            <span class="un">个</span>
                                            </a>
                                        </li>-->
                                        </ul>
                                    </div>
                                </div>
                            </div>
			    <!--新农村建设-->
			     <div class="show_newVillage">
                            	<div class="resource-con show_newVillage_bg">
                                    <div class="panel-body" style="padding-left:40px;">
                                    	<div style="margin-bottom:10px;"><span class="info_tit info_tit5">新农村建设</span></div>
                                        <ul>
                                           <li>
					   <a href="javascript:void(0);" class="cqLinks" title="点击查看详情"   onclick="findItemInfoInVillage('XncJsJbxx');" data-toggle="modal" data-target="#myModal13">
                                            <span>新农村建设信息:</span>
                                            <span class="add-num XncJsJbxx" id="superM1_num" data-toggle="modal" data-target="#myModal13">0</span>
                                            <span class="un">个</span>
                                            </a>
                                           
                                        </li>
                                        </ul>
                                    </div>
                                </div>
                                	
                            </div>
                           
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


    <div class="modal fade" id="myModal11" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true" style="display:none;z-index:999999;">
	<div class="modal-dialog">
	    <div class="modal-content" style="height:380px; overflow-y:scroll; border:none;">
		
	    </div>
	</div>
    </div>
    <!--弹框js开始-->
	<script>
	$(function () { $('#myModal11').modal({
		keyboard: true,
		show:false
	});});
	</script>
    <#include "/template/sn_footer.ftl">
    <!--footer结束-->
</body>
</html>
