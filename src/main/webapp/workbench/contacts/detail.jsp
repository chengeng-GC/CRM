<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" +     request.getServerPort() + request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>" >
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>

	<%--	时间选择器（日历）控件--%>
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

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

		showRemarkList();
		showActivityList();

		//给关联市场活动模态窗口搜索框绑定敲击回车事件
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

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked", this.checked);
		})
		//动态生成的元素，不能以普通绑定事件的方式来操作，要以on的方式来触发事件
		//语法：
		//$(需要绑定元素的有效的外层元素 ).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
		$("#model-activityBody").on("click", $("input[name=xz]"), function () {
			$("#qx").prop("checked", $("input[name=xz]").length == $("input[name=xz]:checked").length);
		})

		//为备注保存按钮添加事件，执行添加操作
		$("#saveRemarkBtn").click(function () {
			var noteContent=$.trim($("#remark").val());
			if (noteContent!=null&&noteContent!=""){
				//执行备注的添加操作
				$.ajax({
					url:"workbench/contacts/saveRemark.do",
					data:{
						"noteContent":$.trim($("#remark").val()),
						"contactsId":"${c.id}"
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
					url:"workbench/contacts/updateRemark.do",
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

//为关联按钮绑定事件，执行关联操作
		$("#bundActivityBtn").click(function () {
			var $xz = $("input[name=xz]:checked");
			if ($xz.length == 0) {
				alert("请选择需要关联的活动");
			} else {
				//拼接data
				var param = "";
				for (var i = 0; i < $xz.length; i++) {
					param += "aid=" + $($xz[i]).val();
					param += "&";
				}
				param += "contactsId=${c.id}";
				$.ajax({
					url: "workbench/contacts/bund.do",
					data: param,
					type: "post",
					dataType: "json",
					success: function (data) {
						if (data.success) {
							showActivityList();
							//复选框全取消
							$("#qx").prop("checked", false);
							//搜索框清空
							$("#aname").val("");
							//市场活动列表清空
							$("#model-activityBody").html("");

							$("#bundActivityModal").modal("hide");
						} else {
							alert("关联失败");
						}
					}
				})
			}
		})
//为删除按钮绑定事件,执行删除操作
		$("#deleteBtn").click(function () {
				//给用户一个提示，避免误删
				if (confirm("确定删除记录吗？")){
					$.ajax({
						url:"workbench/contacts/delete.do",
						data:{"id":"${c.id}"},
						type: "post",
						dataType:"json",
						success:function(data){
							if (data.success){
								//删除成功后,返回index页面
								window.location.href="workbench/contacts/index.jsp";
							}else {
								alert("删除联系人失败");
							}
						}
					})
				}
		})

		//为修改按钮绑定事件，打开修改操作的模态窗口
		$("#editBtn").click(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
				var id="${c.id}";
				$.ajax({
					url:"workbench/contacts/getUserListAndContacts.do",
					data:{"id":id
					},
					type: "get",
					dataType:"json",
					success:function(data){
						//用户列表uList
						//单条 c
						var html="";
						$.each(data.uList,function (i,n) {
							html +="<option value='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-owner").html(html);
						//处理单条contacts
						$("#hidden-edit-id").val(data.c.id);
						$("#edit-owner").val(data.c.owner);
						$("#edit-source").val(data.c.source);
						$("#edit-customerName").val(data.c.customerId);
						$("#edit-fullname").val(data.c.fullname);
						$("#edit-appellation").val(data.c.appellation);
						$("#edit-email").val(data.c.email);
						$("#edit-mphone").val(data.c.mphone);
						$("#edit-job").val(data.c.job);
						$("#edit-birth").val(data.c.birth);
						$("#edit-description").val(data.c.description);
						$("#edit-contactSummary").val(data.c.contactSummary);
						$("#edit-nextContactTime").val(data.c.nextContactTime);
						$("#edit-address").val(data.c.address);
						//处理完毕后,展现模态窗口
						$("#editContactsModal").modal("show");
					}
				})

		})

		//为更新按钮绑定事件，执行更新操作
		$("#updateBtn").click(function () {
			$.ajax({
				url:"workbench/contacts/update.do",
				data:{
					"id":$.trim($("#hidden-edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),
					"source":$.trim($("#edit-source").val()),
					"customerName":$.trim($("#edit-customerName").val()),
					"fullname":$.trim($("#edit-fullname").val()),
					"appellation":$.trim($("#edit-appellation").val()),
					"email":$.trim($("#edit-email").val()),
					"mphone":$.trim($("#edit-mphone").val()),
					"job":$.trim($("#edit-job").val()),
					"birth":$.trim($("#edit-birth").val()),
					"description":$.trim($("#edit-description").val()),
					"contactSummary":$.trim($("#edit-contactSummary").val()),
					"nextContactTime":$.trim($("#edit-nextContactTime").val()),
					"address":$.trim($("#edit-address").val())
				},
				type: "post",
				dataType:"json",
				success:function(data){
					if (data.success){
						//更新成功后,刷新下页面
						window.location.href="workbench/contacts/detail.do?id=${c.id}";
					}else {
						alert("更新联系人失败");
					}
					//关闭模态窗口
					$("#editContactsModal").modal("hide");
				}
			})
		})


	});


	function showModelActivityList() {
		var name = $.trim($("#aname").val())
		//查询并展现市场活动列表,排除已经关联的活动
		$.ajax({
			url: "workbench/contacts/showAcitivityListByNameExceptConid.do",
			data: {
				"name": name,
				"contactsId": "${c.id}"
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				//aList
				var html = "";
				$.each(data, function (i, n) {
					html += '<tr>';
					html += '	<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
					html += '	<td>'+n.name+'</td>';
					html += '	<td>'+n.startDate+'</td>';
					html += '	<td>'+n.endDate+'</td>';
					html += '	<td>'+n.owner+'</td>';
					html += '</tr>';
				})
				$("#model-activityBody").html(html)
			}
		})
	}

	function unbundActivity(id) {
		//让传过来的id是relation表的id
		$.ajax({
			url: "workbench/contacts/unbund.do",
			data: {
				"id": id
			},
			type: "post",
			dataType: "json",
			success: function (data) {
				if (data.success) {
					showActivityList();
				} else {
					alert("解除关联失败");
				}
			}
		})
	}

	function showActivityList() {

		$.ajax({
			url: "workbench/contacts/showActivityListByConid.do",
			data: {
				"contactsId": "${c.id}"
			},
			type: "get",
			dataType: "json",
			success: function (data) {
				// aList
				var html = "";
				$.each(data, function (i, n) {
				html += '<tr>';
				html += '	<td><a href="workbench/activity/detail.do" style="text-decoration: none;">'+n.name+'</a></td>';
				html += '	<td>'+n.startDate+'</td>';
				html += '	<td>'+n.endDate+'</td>';
				html += '	<td>'+n.owner+'</td>';
				html += '	<td><a href="javascript:void(0);" onclick="unbundActivity(\'' + n.id + '\')"  style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>';
				html += '</tr>';
				})
				$("#activityBody").html(html);
			}
		})
	}

	function showRemarkList() {
		$.ajax({
			url: "workbench/contacts/showRemarkListByCid.do",
			data: {
				"contactsId": "${c.id}"
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
				html += '	<font color="gray">联系人</font> <font color="gray">-</font> <b>${c.fullname}${c.appellation}-${c.customerId}</b> <small style="color: gray;">'+(n.editFlag==0?n.createTime:n.editTime)+'由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
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



	function deleteRemark(id) {
		$.ajax({
			url:"workbench/contacts/deleteRemark.do",
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

	function editRemark(id) {
		//获取指定id对应的noteContent信息，并赋予给修改备注模态窗口中的内容文本域和隐藏域
		var noteContent=$("#"+id).find("h5").html();
		$("#noteContent").val(noteContent);
		$("#hidden-remarkNoteContent").val(noteContent);
		//将id赋予给修改备注模态窗口中的隐藏域
		$("#hidden-remarkId").val(id);
		$("#editRemarkModal").modal("show");
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

	
	<!-- 联系人和市场活动关联的模态窗口 -->
	<div class="modal fade" id="bundActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 80%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">关联市场活动</h4>
				</div>
				<div class="modal-body">
					<div class="btn-group" style="position: relative; top: 18%; left: 8px;">
						<form class="form-inline" role="form">
						  <div class="form-group has-feedback">
						    <input type="text" id="aname" class="form-control" style="width: 300px;" placeholder="请输入市场活动名称，支持模糊查询">
						    <span class="glyphicon glyphicon-search form-control-feedback"></span>
						  </div>
						</form>
					</div>
					<table id="activityTable2" class="table table-hover" style="width: 900px; position: relative;top: 10px;">
						<thead>
							<tr style="color: #B3B3B3;">
								<td><input type="checkbox" id="qx"/></td>
								<td>名称</td>
								<td>开始日期</td>
								<td>结束日期</td>
								<td>所有者</td>
								<td></td>
							</tr>
						</thead>
						<tbody id="model-activityBody">
<%--							<tr>--%>
<%--								<td><input type="checkbox"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
<%--							<tr>--%>
<%--								<td><input type="checkbox"/></td>--%>
<%--								<td>发传单</td>--%>
<%--								<td>2020-10-10</td>--%>
<%--								<td>2020-10-20</td>--%>
<%--								<td>zhangsan</td>--%>
<%--							</tr>--%>
						</tbody>
					</table>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">取消</button>
					<button type="button" class="btn btn-primary" id="bundActivityBtn">关联</button>
				</div>
			</div>
		</div>
	</div>

<!-- 修改联系人的模态窗口 -->
<div class="modal fade" id="editContactsModal" role="dialog">
	<div class="modal-dialog" role="document" style="width: 85%;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal">
					<span aria-hidden="true">×</span>
				</button>
				<h4 class="modal-title" id="myModalLabel1">修改联系人</h4>
			</div>
			<div class="modal-body">
				<form class="form-horizontal" role="form">
					<input type="hidden" id="hidden-edit-id">
					<div class="form-group">
						<label for="edit-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-owner">

							</select>
						</div>
						<label for="edit-clueSource1" class="col-sm-2 control-label">来源</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-source">
								<option></option>
								<c:forEach items="${source}" var="s">
									<option value="${s.value}">${s.text}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-fullname" >
						</div>
						<label for="edit-call" class="col-sm-2 control-label">称呼</label>
						<div class="col-sm-10" style="width: 300px;">
							<select class="form-control" id="edit-appellation">
								<option></option>
								<c:forEach items="${appellation}" var="a">
									<option value="${a.value}">${a.text}</option>
								</c:forEach>
							</select>
						</div>
					</div>

					<div class="form-group">
						<label for="edit-job" class="col-sm-2 control-label">职位</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-job">
						</div>
						<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-mphone">
						</div>
					</div>

					<div class="form-group">
						<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-email" >
						</div>
						<label for="edit-birth" class="col-sm-2 control-label">生日</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control time" id="edit-birth" readonly>
						</div>
					</div>

					<div class="form-group">
						<label for="edit-customerName" class="col-sm-2 control-label">客户名称</label>
						<div class="col-sm-10" style="width: 300px;">
							<input type="text" class="form-control" id="edit-customerName" placeholder="支持自动补全，输入客户不存在则新建" >
						</div>
					</div>

					<div class="form-group">
						<label for="edit-describe" class="col-sm-2 control-label">描述</label>
						<div class="col-sm-10" style="width: 81%;">
							<textarea class="form-control" rows="3" id="edit-description"></textarea>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>

					<div style="position: relative;top: 15px;">
						<div class="form-group">
							<label for="edit-contactSummary" class="col-sm-2 control-label">联系纪要</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
							</div>
						</div>
						<div class="form-group">
							<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-nextContactTime" readonly>
							</div>
						</div>
					</div>

					<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

					<div style="position: relative;top: 20px;">
						<div class="form-group">
							<label for="edit-address2" class="col-sm-2 control-label">详细地址</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="1" id="edit-address"></textarea>
							</div>
						</div>
					</div>
				</form>

			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
				<button type="button" class="btn btn-primary" id="updateBtn">更新</button>
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
			<h3>${c.fullname}${c.appellation} <small> - ${c.customerId}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn" ><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">来源</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.source}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">客户名称</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.customerId}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">姓名</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.fullname}${c.appellation}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">邮箱</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.email}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">手机</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.mphone}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">职位</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.job}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">生日</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.birth}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${c.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 60px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${c.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 70px;">
			<div style="width: 300px; color: gray;">联系纪要</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					&nbsp;${c.contactSummary}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 80px;">
			<div style="width: 300px; color: gray;">下次联系时间</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.nextContactTime}&nbsp;</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
        <div style="position: relative; left: 40px; height: 30px; top: 90px;">
            <div style="width: 300px; color: gray;">详细地址</div>
            <div style="width: 630px;position: relative; left: 200px; top: -20px;">
                <b>
					${c.address}
                </b>
            </div>
            <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
        </div>
	</div>
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 20px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
<%--		<!-- 备注1 -->--%>
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>哎呦！</h5>--%>
<%--				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>--%>
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
<%--				<font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>--%>
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
	
	<!-- 交易 -->
	<div>
		<div style="position: relative; top: 20px; left: 40px;">
			<div class="page-header">
				<h4>交易</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable3" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>金额</td>
							<td>阶段</td>
							<td>可能性</td>
							<td>预计成交日期</td>
							<td>类型</td>
							<td></td>
						</tr>
					</thead>
					<tbody>
						<tr>
							<td><a href="transaction/detail.html" style="text-decoration: none;">动力节点-交易01</a></td>
							<td>5,000</td>
							<td>谈判/复审</td>
							<td>90</td>
							<td>2017-02-07</td>
							<td>新业务</td>
							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>
						</tr>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="transaction/save.html" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建交易</a>
			</div>
		</div>
	</div>
	
	<!-- 市场活动 -->
	<div>
		<div style="position: relative; top: 60px; left: 40px;">
			<div class="page-header">
				<h4>市场活动</h4>
			</div>
			<div style="position: relative;top: 0px;">
				<table id="activityTable" class="table table-hover" style="width: 900px;">
					<thead>
						<tr style="color: #B3B3B3;">
							<td>名称</td>
							<td>开始日期</td>
							<td>结束日期</td>
							<td>所有者</td>
							<td></td>
						</tr>
					</thead>
					<tbody id="activityBody">
<%--						<tr>--%>
<%--							<td><a href="workbench/activity/detail.do" style="text-decoration: none;">发传单</a></td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td><a href="javascript:void(0);" data-toggle="modal" data-target="#unbundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>解除关联</a></td>--%>
<%--						</tr>--%>
					</tbody>
				</table>
			</div>
			
			<div>
				<a href="javascript:void(0);"data-toggle="modal" data-target="#bundActivityModal" style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>关联市场活动</a>
			</div>
		</div>
	</div>
	
	
	<div style="height: 200px;"></div>
</body>
</html>