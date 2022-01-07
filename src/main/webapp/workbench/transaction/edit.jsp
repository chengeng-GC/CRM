<%@ page import="java.util.Set" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" +     request.getServerPort() + request.getContextPath();
	Map<String,String> pMap= (Map<String, String>) application.getAttribute("pMap");
	Set<String> set=pMap.keySet();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>/crm" >

	<meta charset="UTF-8"http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<%--	时间选择器（日历）控件--%>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<%--	自动补全插件--%>
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">
	var json={
		<%
        for (String key:set){
            String value=pMap.get(key);
        %>
		"<%=key%>":<%=value%>,
		<%
        }
        %>

	};

	$(function () {

		//自动补全插件
		$("#edit-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/transaction/getCustomerName.do",
						{ "name" : query },
						function (data) {
							//alert(data);
							//客户名称String [{名称1},{名称2]]

							process(data);
						},
						"json"
				);
			},
			delay: 500
		});


		$("#edit-expectedDate").click(function () {
			//时间（日历）选择控件
			$(".timeB").datetimepicker({
				minView: "month",
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			$("#edit-expectedDate").blur();
		})

		$("#edit-nextContactTime").click(function () {
			//时间（日历）选择控件
			$(".timeT").datetimepicker({
				minView: "month",
				language: 'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});
			$("#edit-nextContactTime").blur();
		})

		$("#edit-stage").change(function () {
			//取得选中的阶段
			var stage=$("#edit-stage").val();
			//取可能性
			var possibility=json[stage];
			$("#edit-possibility").val(possibility);
		})

//给查找市场活动模态窗口搜索框绑定敲击回车事件
		$("#aname").keydown(function (event) {

			if (event.keyCode == 13) {
				showModelActivityList();
				//展现完后，要将模态窗口默认的回车行为（默认会刷新页面）禁用掉
				return false;
			}
		})
		//给关联市场活动模态窗口搜索框绑定失去焦点事件
		$("#aname").blur(function () {
			showModelActivityList();
		})

		//为市场活动radio绑定事件
		$("#model-activityBody").on("click",$("input:radio[name=activity]"),function () {
			if ($("input[name=activity]:checked").length!=0){
				var id=$("input[name=activity]:checked").val();
				var name=$("#n"+id).html();
				var flag=$("#hidden-activityId").val();
				if (id!=flag) {
					$("#hidden-activityId").val(id);
					$("#edit-activityId").val(name);
					$("#findActivity").modal("hide");
				}
			}
		})

		//给查找联系人模态窗口搜索框绑定敲击回车事件
		$("#cname").keydown(function (event) {

			if (event.keyCode == 13) {
				showModelContactsList();
				//展现完后，要将模态窗口默认的回车行为（默认会刷新页面）禁用掉
				return false;
			}
		})
		//给查找联系人模态窗口搜索框绑定失去焦点事件
		$("#cname").blur(function () {
			showModelContactsList();
		})

		//联系人radio绑定事件
		$("#model-contactsBody").on("click",$("input:radio[name=contacts]"),function () {
			if ($("input[name=contacts]:checked").length!=0){
				var id=$("input[name=contacts]:checked").val();
				var name=$("#n"+id).html();
				var flag=$("#hidden-contactsId").val();
				if (id!=flag) {
					$("#hidden-contactsId").val(id);
					$("#edit-contactsId").val(name);
					$("#findContacts").modal("hide");
				}
			}
		})

//为添加按钮绑定事件，提交表单
		$("#updateBtn").click(function () {
			var name=$.trim($("#edit-name").val());
			if (name==null||name=="") {
				alert("名称不能为空");
				return ;
			}
			var customerName=$.trim($("#edit-customerName").val());
			if (customerName==null||customerName=="") {
				alert("客户名称不能为空");
				return ;
			}
			$("#tranForm").submit();

		})



	});

	function showModelContactsList() {
		var name = $.trim($("#cname").val())
		//查询并展现市场活动列表,排除已经关联的活动
		$.ajax({
			url: "workbench/transaction/getContactsListByName.do",
			data: {
				"name": name,
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				//aList
				var html = "";
				$.each(data, function (i, n) {
					html += '<tr>';
					html += '	<td><input type="radio" id="'+n.id+'"  name="contacts" value="'+n.id+'"/></td>';
					html += '	<td id="n'+n.id+'">'+n.fullname+'</td>';
					html += '	<td>'+n.email+'</td>';
					html += '	<td>'+n.mphone+'</td>';
					html += '</tr>';
				})
				$("#model-contactsBody").html(html)
				var id= $("#hidden-contactsId").val();
				if (id!=null&&id!=""){
					$("#"+id).attr("checked",true);
				}
			}
		})
	}

	function showModelActivityList() {
		var name = $.trim($("#aname").val())
		$.ajax({
			url: "workbench/transaction/showAcitivityListByName.do",
			data: {
				"name": name,
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				//aList
				var html = "";
				$.each(data, function (i, n) {
					html += '<tr>';
					html += '	<td><input type="radio" id="'+n.id+'"  name="activity" value="'+n.id+'"/></td>';
					html += '	<td id="n'+n.id+'">'+n.name+'</td>';
					html += '	<td>'+n.startDate+'</td>';
					html += '	<td>'+n.endDate+'</td>';
					html += '	<td>'+n.owner+'</td>';
					html += '</tr>';
				})
				$("#model-activityBody").html(html)
				var id= $("#hidden-activityId").val();
				if (id!=null&&id!=""){
					$("#"+id).attr("checked",true);
				}
			}
		})
	}
</script>
</head>
<body>

<!-- 查找市场活动 -->
<div class="modal fade" id="findActivity" role="dialog">
	<div class="modal-dialog" role="document" style="width: 80%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title">查找市场活动</h4>
			</div>
			<div class="modal-body">
				<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
					<form class="form-inline" role="form">
						<div class="form-group has-feedback">
							<input type="text" class="form-control" id="aname" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
							<span class="glyphicon glyphicon-search form-control-feedback"></span>
						</div>
					</form>
				</div>
				<table id="activityTable3" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
					<thead>
					<tr style="color: #B3B3B3;">
						<td></td>
						<td>名称</td>
						<td>开始日期</td>
						<td>结束日期</td>
						<td>所有者</td>
					</tr>
					</thead>
					<tbody id="model-activityBody">
					<%--							<tr>--%>
					<%--								<td><input type="radio" name="activity"/></td>--%>
					<%--								<td>发传单</td>--%>
					<%--								<td>2020-10-10</td>--%>
					<%--								<td>2020-10-20</td>--%>
					<%--								<td>zhangsan</td>--%>
					<%--							</tr>--%>
					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>


<!-- 查找联系人 -->
<div class="modal fade" id="findContacts" role="dialog">
	<div class="modal-dialog" role="document" style="width: 80%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title">查找联系人</h4>
			</div>
			<div class="modal-body">
				<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
					<form class="form-inline" role="form">
						<div class="form-group has-feedback">
							<input type="text" class="form-control" id="cname" style="width: 300px;" placeholder="请输入联系人名称，支持模糊查询">
							<span class="glyphicon glyphicon-search form-control-feedback"></span>
						</div>
					</form>
				</div>
				<table id="activityTable" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
					<thead>
					<tr style="color: #B3B3B3;">
						<td></td>
						<td>名称</td>
						<td>邮箱</td>
						<td>手机</td>
					</tr>
					</thead>
					<tbody id="model-contactsBody">
					<%--							<tr>--%>
					<%--								<td><input type="radio" name="activity"/></td>--%>
					<%--								<td>李四</td>--%>
					<%--								<td>lisi@bjpowernode.com</td>--%>
					<%--								<td>12345678901</td>--%>
					<%--							</tr>--%>

					</tbody>
				</table>
			</div>
		</div>
	</div>
</div>
	
	
	<div style="position:  relative; left: 30px;">
		<h3>更新交易</h3>
	  	<div style="position: relative; top: -40px; left: 70%;">
			<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
			<button type="button" class="btn btn-default" onclick="window.location.href='workbench/transaction/index.jsp';">取消</button>
		</div>
		<hr style="position: relative; top: -40px;">
	</div>
	<form class="form-horizontal" id="tranForm" action="workbench/transaction/update.do"  role="form" style="position: relative; top: -30px;">
		<input type="hidden" value="${t.id}" name="id">
		<div class="form-group">
			<label for="edit-transactionOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-transactionOwner" name="owner">
					<c:forEach items="${uList}" var="u">
						<option value="${u.id}" ${t.owner eq u.id?"selected":""}>${u.name}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-amountOfMoney" class="col-sm-2 control-label">金额</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-amountOfMoney" name="money" value="${t.money}">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-transactionName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-name" name="name" value="${t.name}">
			</div>
			<label for="edit-expectedClosingDate" class="col-sm-2 control-label">预计成交日期<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control timeB" id="edit-expectedDate" name="expectedDate" value="${t.expectedDate}" readonly>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-accountName" class="col-sm-2 control-label">客户名称<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-customerName" value="${t.customerId}" name="customerName" placeholder="支持自动补全，输入客户不存在则新建">
			</div>
			<label for="edit-transactionStage" class="col-sm-2 control-label">阶段<span style="font-size: 15px; color: red;">*</span></label>
			<div class="col-sm-10" style="width: 300px;">
			  <select class="form-control" id="edit-stage" name="stage" >
			  	<option></option>
				  <c:forEach items="${stage}" var="s">
					  <option value="${s.value}" ${t.stage eq s.value?"selected":""}>${s.text}</option>
				  </c:forEach>
			  </select>
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-transactionType" class="col-sm-2 control-label">类型</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-transactionType" name="type">
				  <option></option>
					<c:forEach items="${transactionType}" var="tt">
						<option value="${tt.value}" ${t.type eq tt.value?"selected":""}>${tt.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-possibility" class="col-sm-2 control-label">可能性</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-possibility" value="${t.possibility}" >
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-clueSource" class="col-sm-2 control-label">来源</label>
			<div class="col-sm-10" style="width: 300px;">
				<select class="form-control" id="edit-clueSource" name="source">
				  <option></option>
					<c:forEach items="${source}" var="s">
						<option value="${s.value}"  ${t.source eq s.value?"selected":""}>${s.text}</option>
					</c:forEach>
				</select>
			</div>
			<label for="edit-activitySrc" class="col-sm-2 control-label">市场活动源&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findActivity"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-activityId" value="${activityName}"  readonly>
				<input type="hidden" id="hidden-activityId" value="${t.activityId}" name="activityId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="edit-contactsName" class="col-sm-2 control-label">联系人名称&nbsp;&nbsp;<a href="javascript:void(0);" data-toggle="modal" data-target="#findContacts"><span class="glyphicon glyphicon-search"></span></a></label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control" id="edit-contactsId" value="${contactsName}"  readonly>
				<input type="hidden" id="hidden-contactsId" value="${t.contactsId}" name="contactsId">
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-describe" class="col-sm-2 control-label">描述</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-describe" name="description">${t.description}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
			<div class="col-sm-10" style="width: 70%;">
				<textarea class="form-control" rows="3" id="edit-contactSummary" name="contactSummary">${t.contactSummary}</textarea>
			</div>
		</div>
		
		<div class="form-group">
			<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
			<div class="col-sm-10" style="width: 300px;">
				<input type="text" class="form-control timeT" id="edit-nextContactTime" name="nextContactTime" value="${t.nextContactTime}" readonly>
			</div>
		</div>
		
	</form>
</body>
</html>