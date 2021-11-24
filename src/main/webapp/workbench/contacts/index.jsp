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
	<%--分页控件--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
	<%--	自动补全插件--%>
	<script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

	<script type="text/javascript">

	$(function(){
		
		//定制字段
		$("#definedColumns > li").click(function(e) {
			//防止下拉菜单消失
	        e.stopPropagation();
	    });



		//自动补全插件
		$("#create-customerName,#edit-customerName").typeahead({
			source: function (query, process) {
				$.get(
						"workbench/contacts/getCustomerName.do",
						{ "name" : query },
						function (data) {
							//List<String>
							//alert(data);
							process(data);
						},
						"json"
				);
			},
			delay: 500
		});

		//页面加载完毕展现联系人列表
		pageList(1,2);

		$("#search-birth").mouseover(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			$("#search-birth").blur();
		})
		//为查询按钮添加绑定事件，触发pageList方法
		$("#searchBtn").click(function () {
			//将搜索框汇中的信息保存到隐藏域中，防止其他途径触发pageList方法用未点击查询的搜索框信息查询
			$("#hidden-fullname").val($.trim($("#search-fullname").val()));
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-customerName").val($.trim($("#search-customerName").val()));
			$("#hidden-source").val($.trim($("#search-source").val()));
			$("#hidden-birth").val($.trim($("#search-birth").val()));

			//应该回到第一页，维持每页展现的记录数
			pageList(1,$("#contactsPage").bs_pagination('getOption','rowsPerPage'));
		})

		//为创建按钮添加绑定事件，打开添加操作的模态窗口
		$("#createBtn").click(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			//走后台，取得用户信息列表，为所有者列表添加option
			$.ajax({
				url : "workbench/contacts/getUserList.do",
				type: "get",
				dataType:"json",
				success:function(data){
					var html="";
					$.each(data,function (i,n) {
						html +="<option value='"+n.id+"'>"+n.name+"</option>";
					})
					$("#create-owner").html(html);
					//当前用户作为下拉列表的默认选项
					//在js中使用el表达式，el表达式一定要套用在字符串中
					$("#create-owner").val("${user.id}");
					//所有者下拉框处理完毕后,展现模态窗口
					$("#createContactsModal").modal("show");
				}
			})
		})

		//为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function () {
			var name=$.trim($("#create-fullname").val());
			if (name==null||name=="") {
				alert("名称不能为空");
				return ;
			}
			var customerName=$.trim($("#create-customerName").val());
			if (customerName==null||customerName=="") {
				alert("客户名称不能为空");
				return ;
			}
			$.ajax({
				url:"workbench/contacts/save.do",
				data:{
					"owner":$.trim($("#create-owner").val()),
					"source":$.trim($("#create-source").val()),
					"customerName":customerName,
					"fullname":name,
					"appellation":$.trim($("#create-appellation").val()),
					"email":$.trim($("#create-email").val()),
					"mphone":$.trim($("#create-mphone").val()),
					"job":$.trim($("#create-job").val()),
					"birth":$.trim($("#create-birth").val()),
					"description":$.trim($("#create-description").val()),
					"contactSummary":$.trim($("#create-contactSummary").val()),
					"nextContactTime":$.trim($("#create-nextContactTime").val()),
					"address":$.trim($("#create-address").val())
				},
				type: "post",
				dataType:"json",
				success:function(data){
					if (data.success){
						//添加成功后，刷新市场活动信息列表（局部刷新）
						//应该回到第一页，维持每页展现的记录数
						pageList(1,$("#contactsPage").bs_pagination('getOption','rowsPerPage'));
						//清空添加操作的模态窗口
						$("#createContactsForm")[0].reset();
						//关闭添加操作的模态窗口
						$("#createContactsModal").modal("hide");
					}
				}
			})
		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked);
		})
		//动态生成的元素，不能以普通绑定事件的方式来操作，要以on的方式来触发事件
		//语法：
		//$(需要绑定元素的有效的外层元素 ).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
		$("#contactsBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
		})

		//为删除按钮绑定事件,执行删除操作
		$("#deleteBtn").click(function () {
			//找到复选框中所有√的jquery对象
			var $xz= $("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要删除的记录");
			}else {
				//给用户一个提示，避免误删
				if (confirm("确定删除所选中记录吗？")){
					//同一个key多个value不建议使用json作为请求参数data的数据形式
					//地址为xxx.do?id=xxx&id=xxx&id=xxx
					//拼接data参数
					var param="";
					//将$xz中的每一个dom对象遍历出来，取其value值，就先当于取得需删除记录的id
					for (var i=0;i<$xz.length;i++){
						param += "id="+$($xz[i]).val();
						//如果不是最后一个元素，需要追加一个&
						if (i<$xz.length-1){
							param+="&";
						}
					}

					$.ajax({
						url:"workbench/contacts/delete.do",
						data:param,
						type: "post",
						dataType:"json",
						success:function(data){
							if (data.success){
								//删除成功后,局部刷新下页面
								//回到第一页，每页条数不变
								pageList(1,$("#contactsPage").bs_pagination('getOption','rowsPerPage'));
							}else {
								alert("删除联系人失败");
							}
						}
					})
				}
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
			var $xz=$("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的记录");
			}else if ($xz.length>1){
				alert("只能选择一条记录进行修改");
			} else {
				var id=$xz.val();
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
			}
		})


		//为更新按钮绑定事件，执行更新操作
		$("#updateBtn").click(function () {
			var name=$.trim($("#edit-fullname").val());
			if (name==null||name=="") {
				alert("名称不能为空");
				return ;
			}
			var customerName=$.trim($("#edit-customerName").val());
			if (customerName==null||customerName=="") {
				alert("客户名称不能为空");
				return ;
			}
			$.ajax({
				url:"workbench/contacts/update.do",
				data:{
					"id":$.trim($("#hidden-edit-id").val()),
					"owner":$.trim($("#edit-owner").val()),
					"source":$.trim($("#edit-source").val()),
					"customerName":$.trim($("#edit-customerName").val()),
					"fullname":name,
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
						//更新成功后,局部刷新下页面
						//当前页数不变，每页的条数不变
						pageList($("#contactsPage").bs_pagination('getOption', 'currentPage'),
								$("#contactsPage").bs_pagination('getOption', 'rowsPerPage'));
					}else {
						alert("更新联系人失败");
					}
					//关闭模态窗口
					$("#editContactsModal").modal("hide");
				}
			})
		})




	});


	function pageList(pageNo,pageSize){

		//消除复选框的√
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中保存的信息取出，重新赋予到搜索框中
		$("#search-fullname").val($.trim($("#hidden-fullname").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-customerName").val($.trim($("#hidden-customerName").val()));
		$("#search-source").val($.trim($("#hidden-source").val()));
		$("#search-birth").val($.trim($("#hidden-birth").val()));
		$.ajax({
			url:"workbench/contacts/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"fullname":$.trim($("#search-fullname").val()),
				"owner":$.trim($("#search-owner").val()),
				"customerName":$.trim($("#search-customerName").val()),
				"source":$.trim($("#search-source").val()),
				"birth":$.trim($("#search-birth").val())

			},
			type: "get",
			dataType:"json",
			success:function(data){
				//联系人列表
				//一会分页插件需要的：查询出来的总记录数
				// {"total":100} int total
				var html="";

				$.each(data.dataList,function (i,n) {

				html += '<tr>';
				html += '	<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
				html += '			<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/contacts/detail.do?id='+n.id+'\';">'+n.fullname+n.appellation+'</a></td>';
				html += '	<td>'+n.customerId+'</td>';
				html += '	<td>'+n.owner+'</td>';
				html += '	<td>'+n.source+'</td>';
				html += '	<td>'+n.birth+'</td>';
				html += '	</tr>';
				})
				$("#contactsBody").html(html);

				//计算总页数
				var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页插件，对前端展现分页相关信息
				$("#contactsPage").bs_pagination({
					currentPage: pageNo, // 页码
					rowsPerPage: pageSize, // 每页显示的记录条数
					maxRowsPerPage: 20, // 每页最多显示的记录条数
					totalPages: totalPages, // 总页数
					totalRows: data.total, // 总记录条数

					visiblePageLinks: 3, // 显示几个卡片

					showGoToPage: true,
					showRowsPerPage: true,
					showRowsInfo: true,
					showRowsDefaultInfo: true,

					onChangePage : function(event, data){
						pageList(data.currentPage , data.rowsPerPage);
					}
				});

			}
		})
	}

	
</script>
</head>
<body>
<input type="hidden" id="hidden-owner">
<input type="hidden" id="hidden-fullname">
<input type="hidden" id="hidden-customerName">
<input type="hidden" id="hidden-source">
<input type="hidden" id="hidden-birth">
<!-- 创建联系人的模态窗口 -->
	<div class="modal fade" id="createContactsModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" onclick="$('#createContactsModal').modal('hide');">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabelx">创建联系人</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" id="createContactsForm" role="form">
					
						<div class="form-group">
							<label for="create-contactsOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								</select>
							</div>
							<label for="create-clueSource" class="col-sm-2 control-label">来源</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-source">
								  <option></option>
								  <c:forEach items="${source}" var="s">
									  <option value="${s.value}">${s.text}</option>
								  </c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
								  <option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-birth" class="col-sm-2 control-label">生日</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-birth" readonly>
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-customerName" class="col-sm-2 control-label">客户名称</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-customerName" placeholder="支持自动补全，输入客户不存在则新建">
							</div>
						</div>
						
						<div class="form-group" style="position: relative;">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime1" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime" readonly>
								</div>
							</div>
						</div>

                        <div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address1" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
                            </div>
                        </div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn">保存</button>
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
	
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>联系人列表</h3>
			</div>
		</div>
	</div>
	
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
	
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">姓名</div>
				      <input class="form-control" type="text" id="search-fullname">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">客户名称</div>
				      <input class="form-control" type="text" id="search-customerName">
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">来源</div>
				      <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${source}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
						</select>
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">生日</div>
				      <input class="form-control time" type="text" id="search-birth" readonly>
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 10px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 20px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx"/></td>
							<td>姓名</td>
							<td>客户名称</td>
							<td>所有者</td>
							<td>来源</td>
							<td>生日</td>
						</tr>
					</thead>
					<tbody id="contactsBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" id="xz" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/contacts/detail.jsp';">李四</a></td>--%>
<%--							<td>动力节点</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>广告</td>--%>
<%--							<td>2000-10-10</td>--%>
<%--						</tr>--%>

					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 10px;">
				<div id="contactsPage"></div>

			</div>
			
		</div>
		
	</div>
</body>
</html>