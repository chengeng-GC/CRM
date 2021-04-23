<%@ page import="java.util.List" %>
<%@ page import="com.cg.crm.settings.domain.DicValue" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.Set" %>
<%@ page import="com.cg.crm.workbench.domain.Tran" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" +     request.getServerPort() + request.getContextPath();

	//准备字典类型为stage的字典值列表
	List<DicValue> dvList= (List<DicValue>) application.getAttribute("stage");
	//准备阶段和可能性之间的对应关系
	Map<String,String> pMap= (Map<String, String>) application.getAttribute("pMap");
	//根据pMap准备key集合
	Set<String> set=pMap.keySet();
	//准备正常阶段和后面丢失阶段的分界点下标
	int point=0;
	for (int i=0;i<dvList.size();i++){
		//取得每一个字典值
		DicValue dv=dvList.get(i);
		//从dv中取得value
		String stage=dv.getValue();
		//根据stage取得possibility
		String possibility=pMap.get(stage);
		//如果可能性为0，说明找到了前面正常阶段和和后面对视阶段的分界点
		if ("0".equals(possibility)){
			point=i;
			break;
		}
	}
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>" >

	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />

<style type="text/css">
.mystage{
	font-size: 20px;
	vertical-align: middle;
	cursor: pointer;
}
.closingDate{
	font-size : 15px;
	cursor: pointer;
	vertical-align: middle;
}
</style>
	
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>

<script type="text/javascript">

	//默认情况下取消和保存按钮是隐藏的
	var cancelAndSaveBtnDefault = true;
	
	$(function(){
		$("#remark").focus(function(){
			if(cancelAndSaveBtnDefault){
				//设置remarkDiv的高度为130px
				$("#remarkDiv").css("height","130px");
				//显示
				$("#cancelAndSaveBtn").show("2000");
				cancelAndSaveBtnDefault = false;
			}
		});
		
		$("#cancelBtn").click(function(){
			//显示
			$("#cancelAndSaveBtn").hide();
			//设置remarkDiv的高度为130px
			$("#remarkDiv").css("height","90px");
			cancelAndSaveBtnDefault = true;
		});
		
		$(".remarkDiv").mouseover(function(){
			$(this).children("div").children("div").show();
		});
		
		$(".remarkDiv").mouseout(function(){
			$(this).children("div").children("div").hide();
		});
		
		$(".myHref").mouseover(function(){
			$(this).children("span").css("color","red");
		});
		
		$(".myHref").mouseout(function(){
			$(this).children("span").css("color","#E6E6E6");
		});
		$("#remarkBody").on("mouseover",".remarkDiv",function(){
			$(this).children("div").children("div").show();
		})
		$("#remarkBody").on("mouseout",".remarkDiv",function(){
			$(this).children("div").children("div").hide();
		})
		
		//阶段提示框
		$(".mystage").popover({
            trigger:'manual',
            placement : 'bottom',
            html: 'true',
            animation: false
        }).on("mouseenter", function () {
                    var _this = this;
                    $(this).popover("show");
                    $(this).siblings(".popover").on("mouseleave", function () {
                        $(_this).popover('hide');
                    });
                }).on("mouseleave", function () {
                    var _this = this;
                    setTimeout(function () {
                        if (!$(".popover:hover").length) {
                            $(_this).popover("hide")
                        }
                    }, 100);
                });


		//页面加载完毕后，展示交易阶段历史
		showHistoryList();
		//
		showRemarkList();

//为更新备注按钮绑定事件，执行更新操作
		$("#updateRemarkBtn").click(function () {
			var noteContent=$.trim($("#noteContent").val());
			var id=$("#hidden-remarkId").val();
			//文本域中内容不能为空
			if (noteContent==null ||noteContent==""){
				alert("内容不能为空");
			}else if (noteContent==$("#hidden-remarkNoteContent").val()){
				alert("该内容无需修改");
			} else{
				$.ajax({
					url:"workbench/transaction/updateRemark.do",
					data:{
						"id":id,
						"noteContent":noteContent
					},
					type: "post",
					dataType:"json",
					success:function(data){
						//success
						if (data.success){
							//局部刷新线索备注
							showRemarkList();
							//关闭模态窗口
							$("#editRemarkModal").modal("hide");
						}else {
							alert("修改备注失败");
						}
					}
				})
			}
		})

		//为备注保存按钮添加事件，执行添加操作
		$("#saveRemarkBtn").click(function () {
			var noteContent=$.trim($("#remark").val());
			if (noteContent!=null&&noteContent!=""){
				//执行备注的添加操作
				$.ajax({
					url:"workbench/transaction/saveRemark.do",
					data:{
						"noteContent":$.trim($("#remark").val()),
						"tranId":"${t.id}"
					},
					type: "post",
					dataType:"json",
					success:function(data){
						//传回success
						if (data.success){
							//将textarea文本域中的信息清空
							$("#remark").val("");
							//执行网页上备注更新
							showRemarkList();
						}else {
							alert("保存备注失败")
						}
					}
				})
			}else {
				alert("内容不能为空");
			}
		})
//为删除按钮绑定事件,执行删除操作
		$("#deleteBtn").click(function () {
			//给用户一个提示，避免误删
			if (confirm("确定删除记录吗？")){
				$.ajax({
					url:"workbench/transaction/delete.do",
					data:{"id":"${t.id}"},
					type: "post",
					dataType:"json",
					success:function(data){
						if (data.success){
							//删除成功后,返回index页面
							window.location.href="workbench/transaction/index.jsp";
						}else {
							alert("删除联系人失败");
						}
					}
				})
			}
		})
	});

	function editRemark(id) {
		//获取指定id对应的noteContent信息，并赋予给修改备注模态窗口中的内容文本域和隐藏域
		var noteContent=$("#"+id).find("h5").html();
		$("#noteContent").val(noteContent);
		$("#hidden-remarkNoteContent").val(noteContent);
		//将id赋予给修改备注模态窗口中的隐藏域
		$("#hidden-remarkId").val(id);
		$("#editRemarkModal").modal("show");
	}

	function deleteRemark(id) {
		$.ajax({
			url:"workbench/transaction/deleteRemark.do",
			data:{
				"id":id
			},
			type: "post",
			dataType:"json",
			success:function(data){
				if (data.success){
					showRemarkList();
				}else {
					alert("删除备注失败");
				}
			}
		})
	}

	function showRemarkList() {
		$.ajax({
			url: "workbench/transaction/showRemarkListByTid.do",
			data: {
				"tranId": "${t.id}"
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				//返回一个List
				var html = "";
				$.each(data, function (i, n) {
					html += '<div class="remarkDiv" id="'+n.id+'" style="height: 60px;">';
					html += '			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
					html += '			<div style="position: relative; top: -40px; left: 40px;" >';
					html += '			<h5>'+n.noteContent+'</h5>';
					html += '	<font color="gray">交易</font> <font color="gray">-</font> <b>${t.customerId}-${t.name}</b> <small style="color: gray;">'+(n.editFlag==0?n.createTime:n.editTime)+'由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
					html += '	<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
					html += '			<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')" ><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '	&nbsp;&nbsp;&nbsp;&nbsp;';
					html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
					html += '	</div>';
					html += '	</div>';
					html += '	</div>';
				})
				$("#remarkHtml").html(html);
			}
		})
	}

	function showHistoryList() {
		$.ajax({
			url:"workbench/transaction/showHistoryListByTranId.do",
			data:{
				"tranId":"${t.id}"
			},
			type: "get",
			dataType:"json",
			success:function(data){
				var html="";
				$.each(data,function (i,n) {
					html += '<tr id="'+n.id+'">'
					html += '<td>'+n.stage+'</td>'
					html += '<td>'+n.money+'</td>'
					html += '<td>'+n.possibility+'</td>'
					html += '<td>'+n.expectedDate+'</td>'
					html += '<td>'+n.createTime+'</td>'
					html += '<td>'+n.createBy+'</td>'
					html += '</tr>'
				})
				$("#tranHistoryBody").html(html);
			}
		})
	}

	function changeStage(stage,i) {
		//改变交易阶段
		//参数： stage需要改变的阶段  i对应下标
		$.ajax({
			url:"workbench/transaction/changeState.do",
			data:{
				"id":"${t.id}",
				"stage":stage,
				//生成交易历史用↓
				"money":"${t.money}",
				"expectedDate":"${t.expectedDate}",
			},
			type: "post",
			dataType:"json",
			success:function(data){
				//success   t对象
				if (data.success){
					//改变阶段成功后，需要在详细信息页上局部刷新刷新阶段，可能性，修改人，修改时间
					$("#stage").html(data.t.stage);
					$("#possibility").html(data.t.possibility);
					$("#editBy").html(data.t.editBy);
					$("#editTime").html(data.t.editTime);

					//将所有的阶段图标重新判断，重新赋予样式及颜色
					changeIcon(stage,i);
					//重新展示阶段历史
					showHistoryList();

				}else {
					alert("阶段变更失败");
				}

			}
		})


	}
	function changeIcon(stage,i) {
		//当前阶段
		var currentStage=stage;
		//当前可能性
		var currentPossibility=$("#possibility").html();
		//当前下标
		var index=i;
		//前面正常阶段和后面丢失阶段的分界点下标
		var point =<%=point%>;

		if (currentPossibility=="0"){
			//遍历前七个
			for (var i=0;i<point;i++){
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-record mystage");
				$("#"+i).css("color","#000000");
			}
			//遍历后两个
			for (var i=point;i<<%=dvList.size()%>;i++){
				if (i==index){
					//当前阶段
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#FF0000");
				}else {
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-remove mystage");
					$("#"+i).css("color","#000000");
				}
			}
		}else {
			for (var i=0;i<point;i++){
				if (i==index){
					//当前阶段
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-map-marker mystage");
					$("#"+i).css("color","#90F790");
				}else if (i<index){
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-ok-circle mystage");
					$("#"+i).css("color","#90F790");
				}else {
					$("#"+i).removeClass();
					$("#"+i).addClass("glyphicon glyphicon-record mystage");
					$("#"+i).css("color","#000000");
				}
			}
			for (var i=point;i<<%=dvList.size()%>;i++){
				$("#"+i).removeClass();
				$("#"+i).addClass("glyphicon glyphicon-remove mystage");
				$("#"+i).css("color","#000000");
			}
		}

	}

	
	
</script>

</head>
<body>

<!-- 修改备注的模态窗口 -->
<div class="modal fade" id="editRemarkModal" role="dialog">
	<%-- 备注的id --%>
	<input type="hidden" id="hidden-remarkId">
	<%--            备注的notecontent--%>
	<input type="hidden" id="hidden-remarkNoteContent">
	<div class="modal-dialog" role="document" style="width: 40%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel">修改备注</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form">
					<div class="form-group">
						<label for="edit-describe" class="col-sm-2 control-label">内容</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="noteContent"></textarea>
						</div>
					</div>
				</form>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="updateRemarkBtn">更新</button>
			</div>
		</div>
	</div>
</div>

	<!-- 返回按钮 -->
	<div style="position: relative; top: 35px; left: 10px;">
		<a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left" style="font-size: 20px; color: #DDDDDD"></span></a>
	</div>
	
	<!-- 大标题 -->
	<div style="position: relative; left: 40px; top: -30px;">
		<div class="page-header">
			<h3>${t.customerId}-${t.name} <small>￥${t.money}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/edit.do?id=${t.id}';"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus" ></span> 删除</button>
		</div>
	</div>

	<!-- 阶段状态 -->

	<div id="stageBody" style="position: relative; left: 40px; top: -50px;">
		阶段&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<%
			//准备当前阶段
			Tran t= (Tran) request.getAttribute("t");
			String currentStage=t.getStage();
			//准备当前阶段可能性
			String currentPossibility=pMap.get(currentStage);

			//判断当前阶段
			if ("0".equals(currentPossibility)){
				//如果当前阶段的可能性为0  前七个一定是黑圈，后两个一个是红叉，一个是黒叉
				for (int i=0;i<dvList.size();i++){
					DicValue dv=dvList.get(i);
					String stage=dv.getValue();
					String possibility=pMap.get(stage);
					if ("0".equals(possibility)){
						//如果遍历出来的阶段的可能性为0，则是叉
						if (stage.equals(currentStage)){
							//如果是当前阶段,红叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #FF0000;">
		</span>
		-------------
		<%
						}else {
							//黑叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #000000;">
		</span>
		-------------
		<%
						}
					}else {
						//遍历出来的阶段可能性不是0,是黑圈
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-record mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #000000;">
		</span>
		-------------
		<%
					}
				}
			}else {
				//如果当前阶段的可能性不为0，前面七个有可能是绿圈，绿色标记，黑圈，后两个一定是黑叉
				//准备当前阶段的下标
				int index=0;
				for (int i=0;i<dvList.size();i++){
					DicValue dv=dvList.get(i);
					String stage=dv.getValue();
					if (stage.equals(currentStage)){
						index=i;
						break;
					}
				}

				for (int i=0;i<dvList.size();i++){
					DicValue dv=dvList.get(i);
					String stage=dv.getValue();
					String possibility=pMap.get(stage);
					if ("0".equals(possibility)){
						//如果遍历出来的阶段的可能性为0，则是黑叉
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-remove mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #000000;" >
		</span>
		-------------
		<%
					}else {
						//遍历出来的阶段可能性不是0
						if(i==index){
							//如果是当前阶段，是绿色标记
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-map-marker mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #90F790;">
		</span>
		-------------
		<%
						}else if (i<index){
							//如果小于当前阶段，是绿圈
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-ok-circle mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #90F790;">
		</span>
		-------------
		<%
						}else if (i>index&&i<point){
							//如果大于当前阶段小于分界点，是黑圈
		%>
		<span id="<%=i%>" onclick="changeStage('<%=stage%>','<%=i%>')"
			  class="glyphicon glyphicon-record mystage"
			  data-toggle="popover" data-placement="bottom"
			  data-content="<%=dv.getText()%>" style="color: #000000;">
		</span>
		-------------
		<%

						}
					}
				}
			}

		%>








<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="资质审查" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="需求分析" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="价值建议" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-ok-circle mystage" data-toggle="popover" data-placement="bottom" data-content="确定决策者" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-map-marker mystage" data-toggle="popover" data-placement="bottom" data-content="提案/报价" style="color: #90F790;"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="谈判/复审"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-record mystage" data-toggle="popover" data-placement="bottom" data-content="成交"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="丢失的线索"></span>--%>
<%--		-------------%>
<%--		<span class="glyphicon glyphicon-remove mystage" data-toggle="popover" data-placement="bottom" data-content="因竞争丢失关闭"></span>--%>
<%--		-------------%>
		<span class="closingDate">${t.expectedDate}</span>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: 0px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">金额</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.money}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}-${t.name}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">预计成交日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.expectedDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">阶段</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="stage">${t.stage}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">类型</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.type}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">可能性</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b id="possibility">${t.possibility}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${t.source}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">市场活动源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${t.activityId}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">联系人名称</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.contactsId}</b></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${t.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${t.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b id="editBy">${t.editBy}&nbsp;&nbsp;</b><small id="editTime" style="font-size: 10px; color: gray;">${t.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${t.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 90px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${t.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 100px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>&nbsp;${t.nextContactTime}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 100px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
<%--		<!-- 备注1 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>哎呦！</h5>--%>
<%--				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>
<%--		--%>
<%--		<!-- 备注2 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>呵呵！</h5>--%>
<%--				<font color="gray">交易</font> <font color="gray">-</font> <b>动力节点-交易01</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>
		<div id="remarkHtml"></div>
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" class="btn btn-primary" id="saveRemarkBtn">保存</button>
				</p>
			</form>
		</div>
	</div>
	
	<!-- 阶段历史 -->
	<div>
		<div style="position: relative; top: 100px; left: 40px;">
			<div class="page-header">
				<h4>阶段历史</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>阶段</td>
							<td>金额</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>创建时间</td>
							<td>创建人</td>
						</tr>
					</thead>
					<tbody id="tranHistoryBody">
<%--						<tr>--%>
<%--							<td>资质审查</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>10</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2016-10-10 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
<%--						<tr>--%>
<%--							<td>需求分析</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>20</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2016-10-20 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
<%--						<tr>--%>
<%--							<td>谈判/复审</td>--%>
<%--							<td>5,000</td>--%>
<%--							<td>90</td>--%>
<%--							<td>2017-02-07</td>--%>
<%--							<td>2017-02-09 10:10:10</td>--%>
<%--							<td>zhangsan</td>--%>
<%--						</tr>--%>
					</tbody>
				</table>
			</div>
			
		</div>
	</div>
	
	<div style="height: 200px;"></div>
	
</body>
</html>