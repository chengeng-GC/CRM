<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%
	String basePath = request.getScheme() + "://" + request.getServerName() + ":" +     request.getServerPort() + request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
	<base href="<%=basePath%>/crm" >
<meta charset="UTF-8" http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">

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
			$("#hidden-owner").val($.trim($("#search-owner").val()));
			$("#hidden-startDate").val($.trim($("#search-startDate").val()));
			$("#hidden-endDate").val($.trim($("#search-endDate").val()));

			//应该回到第一页，维持每页展现的记录数
			pageList(1,$("#activityPage").bs_pagination('getOption','rowsPerPage'));
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


			//走后台，取得用户信息列表，为所有者列表添加option
			$.ajax({
				url : "workbench/activity/getUserList.do",
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
					$("#createActivityModal").modal("show");

				}
			})

		})

		//为保存按钮绑定事件，执行添加操作
		$("#saveBtn").click(function () {
			var name=$.trim($("#create-name").val());
			if (name!=null&&name!=""){
			$.ajax({
				url:"workbench/activity/save.do",
				data:{
					"owner":$.trim($("#create-owner").val()),
					"name":name,
					"startDate":$.trim($("#create-startDate").val()),
					"endDate":$.trim($("#create-endDate").val()),
					"cost":$.trim($("#create-cost").val()),
					"description":$.trim($("#create-description").val())
				},
				type: "post",
				dataType:"json",
				success:function(data){
					if (data.success){
						//添加成功后，刷新市场活动信息列表（局部刷新）
						//应该回到第一页，维持每页展现的记录数
						pageList(1,$("#activityPage").bs_pagination('getOption','rowsPerPage'));
						//清空添加操作的模态窗口
                        //注意：
                        //我们拿到了form表单的jquery对象
                        //对于表单的jquery对象，提供了submit（）方法让我们提交表单
                        //但是表单的jquery对象，没有为我们提供reset（）方法让我们重置表单
                        //（坑：idea为我们提示了有reset（）方法）
                        //虽然jquery对象没有为我们提供reset方法，但是原生js为我们提供了reset方法
                        //所以我们要将jquery对象转换为原生dom对象
                        //jquery对象转换为dom对象：jquery对象[下标]
                        //dom对象转换为jquery对象：$（dom)
						$("#activityAddForm")[0].reset();
						//关闭添加操作的模态窗口
						$("#createActivityModal").modal("hide");
					}
				}
			})
		}else {
				alert("名称不能为空")
			}
		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked);
		})
		//动态生成的元素，不能以普通绑定事件的方式来操作，要以on的方式来触发事件
		//语法：
		//$(需要绑定元素的有效的外层元素 ).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
		$("#activityBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
		})

		//为删除按钮绑定事件,执行市场活动删除操作
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
						url:"workbench/activity/delete.do",
						data:param,
						type: "post",
						dataType:"json",
						success:function(data){
							if (data.success){
								//删除成功后,局部刷新下页面
								//回到第一页，每页条数不变
								pageList(1,$("#activityPage").bs_pagination('getOption','rowsPerPage'));
							}else {
								alert("删除市场活动失败");
							}
						}
					})
				}
			}
		})

        //为修改按钮绑定事件，打开修改操作的模态窗口
        $("#editBtn").click(function () {
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
                    url:"workbench/activity/getUserListAndActivity.do",
                    data:{"id":id
                    },
                    type: "get",
                    dataType:"json",
                    success:function(data){
                        //用户列表ulist
                        //市场活动单条 a
                        var html="";
                        $.each(data.ulist,function (i,n) {
                            html +="<option value='"+n.id+"'>"+n.name+"</option>";
                        })
                        $("#edit-owner").html(html);
                        //当前用户作为下拉列表的默认选项
                        $("#edit-owner").val("${user.id}");

                        //处理单条activity
                        $("#edit-hidden-id").val(data.a.id);
                        $("#edit-name").val(data.a.name);
                        $("#edit-owner").val(data.a.owner);
                        $("#edit-startDate").val(data.a.startDate);
                        $("#edit-endDate").val(data.a.endDate);
                        $("#edit-cost").val(data.a.cost);
                        $("#edit-description").val(data.a.description);

                        //处理完毕后,展现模态窗口
                        $("#editActivityModal").modal("show");
                    }
                })
            }
        })

		//为更新按钮绑定事件，执行更新操作
		$("#updateBtn").click(function () {
			var name=$.trim($("#edit-name").val());
			if (name!=null&&name!="") {
				$.ajax({
					url: "workbench/activity/update.do",
					data: {
						"id": $.trim($("#edit-hidden-id").val()),
						"owner": $.trim($("#edit-owner").val()),
						"name": name,
						"startDate": $.trim($("#edit-startDate").val()),
						"endDate": $.trim($("#edit-endDate").val()),
						"cost": $.trim($("#edit-cost").val()),
						"description": $.trim($("#edit-description").val())
					},
					type: "post",
					dataType: "json",
					success: function (data) {
						if (data.success) {
							//更新成功后,局部刷新下页面
							//当前页数不变，每页的条数不变
							pageList($("#activityPage").bs_pagination('getOption', 'currentPage'),
									$("#activityPage").bs_pagination('getOption', 'rowsPerPage'));
						} else {
							alert("更新市场活动失败");
						}
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
					}
				})
			}else {
				alert("名称不能为空")
			}
		})


	});

	//对于所有的关系型数据库，做前端的分页相关操作的基础组件就是pageNo页码和pageSize每页条数
	//发出ajax请求到后台，从后台取得最新的市场活动信息列表数据,通过响应回来的数据，局部刷新市场活动信息列表
	// 		我们都在哪些情况下，需要用pagelist方法（什么情况下需要刷新一下市场活动列表）
	// 		（1）点击左侧菜单中的”市场活动"超链接，需要刷新市场活动列表，
	// 		（2）添加，修改，删除后，需要刷新市场活动列表
	// 		（3）点击查询按钮的时候，需要刷新市场活动列表
	// 		（4）点击分页组件的时候
	function pageList(pageNo,pageSize){
		//消除复选框的√
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中保存的信息取出，重新赋予到搜索框中
		$("#search-name").val($.trim($("#hidden-name").val()));
		$("#search-owner").val($.trim($("#hidden-owner").val()));
		$("#search-startDate").val($.trim($("#hidden-startDate").val()));
		$("#search-endDate").val($.trim($("#hidden-endDate").val()));

		$.ajax({
			url:"workbench/activity/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"name":$.trim($("#search-name").val()),
				"owner":$.trim($("#search-owner").val()),
				"startDate":$.trim($("#search-startDate").val()),
				"endDate":$.trim($("#search-endDate").val())
			},
			type: "get",
			dataType:"json",
			success:function(data){
				//我们需要的：市场活动信息列表
				//[{市场活动1}，{2},（3}] list<Activity>
				//一会分页插件需要的：查询出来的总记录数
				// {"total":100} int total
				// data:{"total":100,"dataList"：[{市场活动1}，{2},（3}]}
				var html="";

				$.each(data.dataList,function (i,n) {
					html += '<tr >';
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/activity/detail.do?id='+n.id+'\';">'+n.name+'</a></td>';
					html += '<td>'+n.owner+'</td>';
					html += '<td>'+n.startDate+'</td>';
					html += '<td>'+n.endDate+'</td>';
					html += '</tr>';
				})
				$("#activityBody").html(html);

				//计算总页数
				var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页插件，对前端展现分页相关信息
				$("#activityPage").bs_pagination({
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
<input type="hidden" id="hidden-owner"/>
<input type="hidden" id="hidden-startDate"/>
<input type="hidden" id="hidden-endDate"/>
	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form id="activityAddForm" class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-owner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								</select>
							</div>
                            <label for="create-name" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-name">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-startDate" readonly>
							</div>
							<label for="create-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
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
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					<input type="hidden" id="edit-hidden-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">

								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" >
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-startDate" readonly >
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control time" id="edit-endDate" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
<%--                             关于文本域textarea:
                                （1）一定是要以标签对的形式来呈现，正常状态下标签对要紧紧的挨着
                                （2）textarea虽然是以标签对的形式来呈现的，但是它也是属于表单元素范畴
                                我们所有的对于textarea的取值和赋值操作，应该统一使用val（）方法（而不是html（）方法）--%>
								<textarea class="form-control" rows="3" id="edit-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" id="updateBtn" class="btn btn-primary" >更新</button>
				</div>
			</div>
		</div>
	</div>
	
	
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="search-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="search-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control" type="text" id="search-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control" type="text" id="search-endDate">
				    </div>
				  </div>
				  
				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
<%--
			    点击创建按钮，观察两个属性和属性值
			    data-toggle="modal":表示触发该按钮，将要打开一个模态窗口
			    data-target="#createActivityModal":表示要打开哪个模态窗口，通过#id的形式找到该窗口
			    现在我们是以属性和属性值的方式写在了button元素中，用来打开模态窗口但是这样做是有问题的：
    			问题在于没有办法对按钮的功能进行扩充
    			所以未来的实际项目开发，对于触发模态窗口的操作，一定不要写死在元素当中，应该由我们自己写s代码来操作
--%>
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" id="deleteBtn" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx" /></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="activityBody">
<%--						<tr class="active">--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--							<td>2020-10-10</td>--%>
<%--							<td>2020-10-20</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/activity/detail.jsp';">发传单</a></td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>2020-10-10</td>--%>
<%--                            <td>2020-10-20</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 30px;">

				<div id="activityPage">

				</div>

			</div>
			
		</div>
		
	</div>
</body>
</html>