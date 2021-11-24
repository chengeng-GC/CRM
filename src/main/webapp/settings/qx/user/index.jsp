<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
String basePath = request.getScheme() + "://" + request.getServerName() + ":" +     request.getServerPort() + request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>" >
<meta charset="UTF-8">
	<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
	<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

	<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
	<%--	时间选择器（日历）控件--%>
	<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
	<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<%--分页控件--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
<script type="text/javascript">
	$(function(){
		//页面加载完毕后触发一个方法，展现页面

		pageList(1,2);

		//为查询按钮添加绑定事件，触发pageList方法
		$("#searchBtn").click(function () {
			//将搜索框汇中的信息保存到隐藏域中，防止其他途径触发pageList方法用未点击查询的搜索框信息查询
			$("#hidden-name").val($.trim($("#search-name").val()));
			$("#hidden-deptno").val($.trim($("#search-deptno").val()));
			$("#hidden-lockState").val($.trim($("#search-lockState").val()));
			$("#hidden-expireTimeF").val($.trim($("#search-expireTimeF").val()));
			$("#hidden-expireTimeB").val($.trim($("#search-expireTimeB").val()));
			//alert($.trim($("#hidden-name").val()));
			/*alert($.trim($("#hidden-deptno").val()));
			alert($.trim($("#hidden-lockState").val()));
			alert($.trim($("#hidden-expireTimeF").val()));
			alert($.trim($("#hidden-expireTimeB").val()));*/
			//应该回到第一页，维持每页展现的记录数
			pageList(1,$("#userPage").bs_pagination('getOption','rowsPerPage'));
		})

		$("#search-expireTimeF").mouseover(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			$("#search-expireTimeF").blur();
		})

		$("#search-expireTimeB").mouseover(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});
			$("#search-expireTimeB").blur();
		})


		//为创建按钮添加绑定事件，打开添加操作的模态窗口
		$("#addBtn").click(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "bottom-left"
			});

			$("#createUserModal").modal("show");
		})

//为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function () {
			var loginAct=$.trim($("#create-loginAct").val());
			var name=$.trim($("#create-name").val());
			var loginPwd=$.trim($("#create-loginPwd").val());
			var confirmPwd=$.trim($("#create-confirmPwd").val());
			var expireTime=$.trim($("#create-expireTime").val());
			var lockState=$.trim($("#create-lockState").val());
			var allowIps=$.trim($("#create-allowIps").val());
			var sign=true;
			if (loginAct==null || loginAct==""){
				sign=false;
				alert("登录账号不能为空")
			}else if (name==null || name==""){
				sign=false;
				alert("用户姓名不能为空")
			}else if (loginPwd==null || loginPwd==""){
				sign=false;
				alert("登录密码不能为空")
			}else if (expireTime==null || expireTime==""){
				sign=false;
				alert("失效时间不能为空")
			}else if (lockState==null || lockState==""){
				sign=false;
				alert("锁定状态不能为空")
			}else if (allowIps==null || allowIps==""){
				sign=false;
				alert("允许访问ip不能为空")
			}else if (loginPwd!=confirmPwd){
				sign=false;
				alert("确认密码与登录密码不同");
			}

			if (sign){
				$.ajax({
					url:"settings/user/save.do",
					data:{
						"loginAct":loginAct,
						"name":name,
						"loginPwd":loginPwd,
						"expireTime":expireTime,
						"lockState":lockState,
						"allowIps":allowIps,
						"email":$.trim($("#create-email").val()),
						"deptno":$.trim($("#create-deptno").val())
					},
					type: "post",
					dataType:"json",
					success:function(data){
						if (data.success){
							//添加成功后，刷新市场活动信息列表（局部刷新）
							//应该回到第一页，维持每页展现的记录数
							pageList(1,$("#userPage").bs_pagination('getOption','rowsPerPage'));
							//清空添加操作的模态窗口
							$("#userAddForm")[0].reset();
							//关闭添加操作的模态窗口
							$("#createUserModal").modal("hide");
						}
					}
				})
			}
		})


	});

		//获取列表并分页
		function pageList(pageNo,pageSize){
			//消除复选框的√
			$("#qx").prop("checked",false);

			//查询前，将隐藏域中保存的信息取出，重新赋予到搜索框中
			$("#search-name").val($.trim($("#hidden-name").val()));
			$("#search-deptno").val($.trim($("#hidden-deptno").val()));
			$("#search-lockState").val($.trim($("#hidden-lockState").val()));
			$("#search-expireTimeF").val($.trim($("#hidden-expireTimeF").val()));
			$("#search-expireTimeB").val($.trim($("#hidden-expireTimeB").val()));


			$.ajax({
				url:"settings/user/pageList.do",
				data:{
					"pageNo":pageNo,
					"pageSize":pageSize,
					"name":$.trim($("#search-name").val()),
					"deptno":$.trim($("#search-deptno").val()),
					"lockState":$.trim($("#search-lockState").val()),
					"expireTimeF":$.trim($("#search-expireTimeF").val()),
					"expireTimeB":$.trim($("#search-expireTimeB").val())
				},
				type: "get",
				dataType:"json",
				success:function(data){
					var html="";
					$.each(data.dataList,function (i,n) {
						html +='<tr>';
						html +='<td><input type="checkbox"  name="xz" value="'+n.id+'"/></td>';
						html +='<td>'+(i+1)+'</td>';
						html +='<td>'+n.loginAct+'</td>';
						html +='<td>'+n.name+'</td>';
						html +='<td>'+n.deptno+'</td>';
						html +='<td>'+n.email+'</td>';
						html +='<td>'+n.expireTime+'</td>';
						html +='<td>'+n.allowIps+'</td>';
						html +='<td>'+n.lockState+'</td>';
						html +='<td>'+n.createBy+'</td>';
						html +='<td>'+n.createTime+'</td>';
						html +='<td>'+n.editBy+'</td>';
						html +='<td>'+n.editTime+'</td>';
						html +='</tr>';
					})
					$("#userBody").html(html);

					//计算总页数
					var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

					//数据处理完毕后，结合分页插件，对前端展现分页相关信息
					$("#userPage").bs_pagination({
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
						//pageList($("#activityPage").bs_pagination('getOption', 'currentPage'),$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						// 这两个参数不需要我们进行任何的修改操作直接使用即可
						// 操作后停留在当前页 $("#activityPage").bs_pagination('getOption','currentPage')
						// 操作后维持已经设置好的每页展现的记录数 $("#activityPage").bs_pagination('getOption','rowsPerPage')
					});
				}
			})
		}

</script>
</head>
<body>
<input type="hidden" id="hidden-name"/>
<input type="hidden" id="hidden-deptno"/>
<input type="hidden" id="hidden-lockState"/>
<input type="hidden" id="hidden-expireTimeF"/>
<input type="hidden" id="hidden-expireTimeB"/>
	<!-- 创建用户的模态窗口 -->
	<div class="modal fade" id="createUserModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">新增用户</h4>
				</div>
				<div class="modal-body">
				
					<form id="userAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-loginActNo" class="col-sm-2 control-label">登录帐号</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-loginAct">
							</div>
							<label for="create-username" class="col-sm-2 control-label">用户姓名</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-name">
							</div>
						</div>
						<div class="form-group">
							<label for="create-loginPwd" class="col-sm-2 control-label">登录密码</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="password" class="form-control" id="create-loginPwd">
							</div>
							<label for="create-confirmPwd" class="col-sm-2 control-label">确认密码</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="password" class="form-control" id="create-confirmPwd">
							</div>
						</div>
						<div class="form-group">
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
							<label for="create-expireTime" class="col-sm-2 control-label">失效时间</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-expireTime">
							</div>
						</div>
						<div class="form-group">
							<%--@declare id="create-org"--%><label for="create-lockStatus" class="col-sm-2 control-label">锁定状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-lockState">
								  <option></option>
								  <option value="1">启用</option>
								  <option value="0">锁定</option>
								</select>
							</div>
							<label for="create-org" class="col-sm-2 control-label">部门</label>
                            <div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-deptno">
                            </div>
						</div>
						<div class="form-group">
							<label for="create-allowIps" class="col-sm-2 control-label">允许访问的IP</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-allowIps" style="width: 280%" placeholder="多个用逗号隔开">
							</div>
						</div>
					</form>
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary"  id="saveBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	
	<div>
		<div style="position: relative; left: 30px; top: -10px;">
			<div class="page-header">
				<h3>用户列表</h3>
			</div>
		</div>
	</div>
	
	<div class="btn-toolbar" role="toolbar" style="position: relative; height: 80px; left: 30px; top: -10px;">
		<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
		  
		  <div class="form-group">
		    <div class="input-group">
		      <div class="input-group-addon">用户姓名</div>
		      <input class="form-control" type="text" id="search-name">
		    </div>
		  </div>
		  &nbsp;&nbsp;&nbsp;&nbsp;
		  <div class="form-group">
		    <div class="input-group">
		      <div class="input-group-addon">部门名称</div>
		      <input class="form-control" type="text" id="search-deptno">
		    </div>
		  </div>
		  &nbsp;&nbsp;&nbsp;&nbsp;
		  <div class="form-group">
		    <div class="input-group">
		      <div class="input-group-addon">锁定状态</div>
			  <select class="form-control" id="search-lockState">
			  	  <option></option>
			      <option>锁定</option>
				  <option>启用</option>
			  </select>
		    </div>
		  </div>
		  <br><br>
		  
		  <div class="form-group">
		    <div class="input-group">
		      <div class="input-group-addon">失效时间</div>
			  <input class="form-control time" type="text" id="search-expireTimeF" />
		    </div>
		  </div>
		  
		  ~
		  
		  <div class="form-group">
		    <div class="input-group">
			  <input class="form-control time" type="text" id="search-expireTimeB" />
		    </div>
		  </div>
		  
		  <button type="button" class="btn btn-default" id="searchBtn">查询</button>
		  
		</form>
	</div>
	
	
	<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px; width: 110%; top: 20px;">
		<div class="btn-group" style="position: relative; top: 18%;">
		  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
		  <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
		
	</div>
	
	<div style="position: relative; left: 30px; top: 40px; width: 110%">
		<table class="table table-hover">
			<thead>
				<tr style="color: #B3B3B3;">
					<td><input type="checkbox" id="qx"/></td>
					<td>序号</td>
					<td>登录帐号</td>
					<td>用户姓名</td>
					<td>部门名称</td>
					<td>邮箱</td>
					<td>失效时间</td>
					<td>允许访问IP</td>
					<td>锁定状态</td>
					<td>创建者</td>
					<td>创建时间</td>
					<td>修改者</td>
					<td>修改时间</td>
				</tr>
			</thead>
			<tbody id="userBody">
<%--				<tr class="active">--%>
<%--					<td><input type="checkbox" /></td>--%>
<%--					<td>1</td>--%>
<%--					<td><a  href="detail.html">zhangsan</a></td>--%>
<%--					<td>张三</td>--%>
<%--					<td>市场部</td>--%>
<%--					<td>zhangsan@bjpowernode.com</td>--%>
<%--					<td>2017-02-14 10:10:10</td>--%>
<%--					<td>127.0.0.1,192.168.100.2</td>--%>
<%--					<td>启用</td>--%>
<%--					<td>admin</td>--%>
<%--					<td>2017-02-10 10:10:10</td>--%>
<%--					<td>admin</td>--%>
<%--					<td>2017-02-10 20:10:10</td>--%>
<%--				</tr>--%>
<%--				<tr>--%>
<%--					<td><input type="checkbox" /></td>--%>
<%--					<td>2</td>--%>
<%--					<td><a  href="detail.html">lisi</a></td>--%>
<%--					<td>李四</td>--%>
<%--					<td>市场部</td>--%>
<%--					<td>lisi@bjpowernode.com</td>--%>
<%--					<td>2017-02-14 10:10:10</td>--%>
<%--					<td>127.0.0.1,192.168.100.2</td>--%>
<%--					<td>锁定</td>--%>
<%--					<td>admin</td>--%>
<%--					<td>2017-02-10 10:10:10</td>--%>
<%--					<td>admin</td>--%>
<%--					<td>2017-02-10 20:10:10</td>--%>
<%--				</tr>--%>
			</tbody>
		</table>
	</div>
	
	<div style="height: 50px; position: relative;top: 30px; left: 30px;">
		<div id="userPage">

		</div>
	</div>
			
</body>
</html>