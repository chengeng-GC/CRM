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
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
<script type="text/javascript">

	$(function(){
		//页面加载完毕局部刷新线索列表
		pageList(1,2);

		//给创建按钮绑定事件，显示创建线索模态窗口
		$("#addBtn").click(function () {
			//时间（日历）选择控件
			$(".time").datetimepicker({
				minView: "month",
				language:  'zh-CN',
				format: 'yyyy-mm-dd',
				autoclose: true,
				todayBtn: true,
				pickerPosition: "top-left"
			});

			//走后台，取得用户信息列表，为所有者列表添加option
			$.ajax({
				url : "workbench/clue/getUserList.do",
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
					$("#createClueModal").modal("show");
				}
			})

			//为保存按钮绑定点击事件，执行保存线索
			$("#saveBtn").click(function () {
				$.ajax({
					url:"workbench/clue/saveClue.do",
					data:{
						"fullname":$.trim($("#create-fullname").val()),
						"appellation":$.trim($("#create-appellation").val()),
						"owner":$.trim($("#create-owner").val()),
						"company":$.trim($("#create-company").val()),
						"job":$.trim($("#create-job").val()),
						"email":$.trim($("#create-email").val()),
						"phone":$.trim($("#create-phone").val()),
						"website":$.trim($("#create-website").val()),
						"mphone":$.trim($("#create-mphone").val()),
						"state":$.trim($("#create-state").val()),
						"source":$.trim($("#create-source").val()),
						"description":$.trim($("#create-description").val()),
						"contactSummary":$.trim($("#create-contactSummary").val()),
						"nextContactTime":$.trim($("#create-nextContactTime").val()),
						"address":$.trim($("#create-address").val())
					},
					type: "post",
					dataType:"json",
					success:function(data){
						//success
						if (data.success){
							//刷新列表
							pageList(1,$("#cluePage").bs_pagination('getOption','rowsPerPage'));

							$("#createClueModal").modal("hide");
						}else {
							alert("创建线索失败");
						}

					}
				})
			})
		})

		//为全选的复选框绑定事件，触发全选操作
		$("#qx").click(function () {
			$("input[name=xz]").prop("checked",this.checked);
		})

		//语法：
		//$(需要绑定元素的有效的外层元素 ).on(绑定事件的方式，需要绑定的元素的jquery对象，回调函数)
		$("#clueBody").on("click",$("input[name=xz]"),function () {
			$("#qx").prop("checked",$("input[name=xz]").length==$("input[name=xz]:checked").length);
		})

		//为查询按钮添加绑定事件，触发pageList方法
		$("#searchBtn").click(function () {
			//将搜索框汇中的信息保存到隐藏域中，防止其他途径触发pageList方法用未点击查询的搜索框信息查询
			$("#hidden-search-fullname").val($.trim($("#search-fullname").val()));
			$("#hidden-search-owner").val($.trim($("#search-owner").val()));
			$("#hidden-search-company").val($.trim($("#search-company").val()));
			$("#hidden-search-phone").val($.trim($("#search-phone").val()));
			$("#hidden-search-mphone").val($.trim($("#search-mphone").val()));
			$("#hidden-search-source").val($.trim($("#search-source").val()));
			$("#hidden-search-state").val($.trim($("#search-state").val()));
			pageList(1,$("#cluePage").bs_pagination('getOption','rowsPerPage'));
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
						url:"workbench/clue/delete.do",
						data:param,
						type: "post",
						dataType:"json",
						success:function(data){
							if (data.success){
								//删除成功后,局部刷新下页面
								//回到第一页，每页条数不变
								pageList(1,$("#cluePage").bs_pagination('getOption','rowsPerPage'));
							}else {
								alert("删除市场活动失败");
							}
						}
					})
				}
			}
		})


		//为修改按钮绑定事件，打开修改线索模态窗口
		$("#editBtn").click(function () {
			var $xz=$("input[name=xz]:checked");
			if ($xz.length==0){
				alert("请选择需要修改的记录");
			}else if ($xz.length>1){
				alert("只能选择一条记录进行修改");
			} else {
				var id=$xz.val();
				$.ajax({
					url:"workbench/clue/getUserListAndClue.do",
					data:{"id":id
					},
					type: "get",
					dataType:"json",
					success:function(data){
						//用户列表ulist
						//线索单条 c
						var html="";
						$.each(data.ulist,function (i,n) {
							html +="<option value='"+n.id+"'>"+n.name+"</option>";
						})
						$("#edit-owner").html(html);
						//当前用户作为下拉列表的默认选项

						$("#edit-owner").val("${user.id}");

						//处理单条clue
						$("#edit-hidden-id").val(data.c.id);
						$("#edit-fullname").val(data.c.fullname);
						$("#edit-appellation").val(data.c.appellation);
						$("#edit-job").val(data.c.job);
						$("#edit-company").val(data.c.company);
						$("#edit-email").val(data.c.email);
						$("#edit-phone").val(data.c.phone);
						$("#edit-website").val(data.c.website);
						$("#edit-mphone").val(data.c.mphone);
						$("#edit-description").val(data.c.description);
						$("#edit-contactSummary").val(data.c.contactSummary);
						$("#edit-nextContactTime").val(data.c.nextContactTime);
						$("#edit-address").val(data.c.address);
						$("#edit-state").val(data.c.state);
						$("#edit-source").val(data.c.source);
						//处理完毕后,展现模态窗口
						$("#editClueModal").modal("show");
						alert(data.c.id);
						alert($("#edit-hidden-id").val());
					}
				})
			}
		})


//为更新按钮绑定事件，执行更新操作
        $("#updateBtn").click(function () {
            $.ajax({
                url:"workbench/clue/update.do",
                data:{
                    "id":$("#edit-hidden-id").val(),
                    "owner":$.trim($("#edit-owner").val()),
                    "appellation":$.trim($("#edit-appellation").val()),
                    "job":$.trim($("#edit-job").val()),
                    "company":$.trim($("#edit-company").val()),
                    "email":$.trim($("#edit-email").val()),
                    "phone":$.trim($("#edit-phone").val()),
                    "website":$.trim($("#edit-website").val()),
                    "mphone":$.trim($("#edit-mphone").val()),
                    "description":$.trim($("#edit-description").val()),
                    "contactSummary":$.trim($("#edit-contactSummary").val()),
                    "nextContactTime":$.trim($("#edit-nextContactTime").val()),
                    "fullname":$.trim($("#edit-fullname").val()),
                    "address":$.trim($("#edit-address").val()),
                    "state":$.trim($("#edit-state").val()),
                    "source":$.trim($("#edit-source").val())
                },
                type: "post",
                dataType:"json",
                success:function(data){
                    if (data.success){
                        //更新成功后,局部刷新下页面
                        //当前页数不变，每页的条数不变
                        pageList($("#cluePage").bs_pagination('getOption', 'currentPage'),
                            $("#cluePage").bs_pagination('getOption', 'rowsPerPage'));
                    }else {
                        alert("更新线索失败");
                    }
                    //关闭模态窗口
                    $("#editClueModal").modal("hide");
                }
            })
        })



	});

	function pageList(pageNo,pageSize) {
		//消除复选框的√
		$("#qx").prop("checked",false);

		//查询前，将隐藏域中保存的信息取出，重新赋予到搜索框中
		$("#search-fullname").val($.trim($("#hidden-search-fullname").val()));
		$("#search-owner").val($.trim($("#hidden-search-owner").val()));
		$("#search-company").val($.trim($("#hidden-search-company").val()));
		$("#search-phone").val($.trim($("#hidden-search-phone").val()));
		$("#search-mphone").val($.trim($("#hidden-search-mphone").val()));
		$("#search-source").val($.trim($("#hidden-search-source").val()));
		$("#search-state").val($.trim($("#hidden-search-state").val()));

		$.ajax({
			url:"workbench/clue/pageList.do",
			data:{
				"pageNo":pageNo,
				"pageSize":pageSize,
				"fullname":$.trim($("#search-fullname").val()),
				"owner":$.trim($("#search-owner").val()),
				"company":$.trim($("#search-company").val()),
				"phone":$.trim($("#search-phone").val()),
				"mphone":$.trim($("#search-mphone").val()),
				"source":$.trim($("#search-source").val()),
				"state":$.trim($("#search-state").val())
			},
			type: "get",
			dataType:"json",
			success:function(data){
				//我们需要的：线索信息列表
				//[{线索1}，{2},（3}] list<Clue>
				//一会分页插件需要的：查询出来的总记录数
				// {"total":100} int total
				// data:{"total":100,"dataList"：[{市场活动1}，{2},（3}]}
				var html="";
				$.each(data.dataList,function (i,n) {
					html += '<tr>'
					html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>'
					html += '<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href=\'workbench/clue/detail.do?id='+n.id+'\';">'+n.fullname+n.appellation+'</a></td>'
					html += '<td>'+n.company+'</td>'
					html += '<td>'+n.phone+'</td>'
					html += '<td>'+n.mphone+'</td>'
					html += '<td>'+n.source+'</td>'
					html += '<td>'+n.owner+'</td>'
					html += '<td>'+n.state+'</td>'
					html += '</tr>'
				})
				$("#clueBody").html(html);

				//计算总页数
				var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

				//数据处理完毕后，结合分页插件，对前端展现分页相关信息
				$("#cluePage").bs_pagination({
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
<input type="hidden" id="hidden-search-fullname">
<input type="hidden" id="hidden-search-company">
<input type="hidden" id="hidden-search-phone">
<input type="hidden" id="hidden-search-source">
<input type="hidden" id="hidden-search-owner">
<input type="hidden" id="hidden-search-mphone">
<input type="hidden" id="hidden-search-state">
	<!-- 创建线索的模态窗口 -->
	<div class="modal fade" id="createClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel">创建线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
					
						<div class="form-group">
							<label for="create-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-owner">
								</select>
							</div>
							<label for="create-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-appellation">
									<option></option>
								  <c:forEach items="${appellation}" var="a">
									  <option value="${a.value}">${a.text}</option>
								  </c:forEach>
								</select>
							</div>
							<label for="create-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-fullname">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-job">
							</div>
							<label for="create-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-email">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-phone">
							</div>
							<label for="create-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-website">
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="create-mphone">
							</div>
							<label for="create-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-state">
									<option></option>
									<c:forEach items="${clueState}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="create-source" class="col-sm-2 control-label">线索来源</label>
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
							<label for="create-describe" class="col-sm-2 control-label">线索描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative;"></div>
						
						<div style="position: relative;top: 15px;">
							<div class="form-group">
								<label for="create-contactSummary" class="col-sm-2 control-label">联系纪要</label>
								<div class="col-sm-10" style="width: 81%;">
									<textarea class="form-control" rows="3" id="create-contactSummary"></textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="create-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control time" id="create-nextContactTime">
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>
						
						<div style="position: relative;top: 20px;">
							<div class="form-group">
                                <label for="create-address" class="col-sm-2 control-label">详细地址</label>
                                <div class="col-sm-10" style="width: 81%;">
                                    <textarea class="form-control" rows="1" id="create-address"></textarea>
                                </div>
							</div>
						</div>
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveBtn" >保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改线索的模态窗口 -->
	<div class="modal fade" id="editClueModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 90%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title">修改线索</h4>
				</div>
				<div class="modal-body">
					<form class="form-horizontal" role="form">
						<input type="hidden" id="edit-hidden-id">
						<div class="form-group">
							<label for="edit-clueOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-owner">
								</select>
							</div>
							<label for="edit-company" class="col-sm-2 control-label">公司<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-company">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-call" class="col-sm-2 control-label">称呼</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-appellation">
								  <option></option>
									<c:forEach items="${appellation}" var="a">
										<option value="${a.value}">${a.text}</option>
									</c:forEach>
								</select>
							</div>
							<label for="edit-surname" class="col-sm-2 control-label">姓名<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-fullname" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-job" class="col-sm-2 control-label">职位</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-job" >
							</div>
							<label for="edit-email" class="col-sm-2 control-label">邮箱</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-email" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-phone" >
							</div>
							<label for="edit-website" class="col-sm-2 control-label">公司网站</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-website" >
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-mphone" class="col-sm-2 control-label">手机</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-mphone" >
							</div>
							<label for="edit-status" class="col-sm-2 control-label">线索状态</label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-state">
								  <option></option>
									<c:forEach items="${clueState}" var="c">
										<option value="${c.value}">${c.text}</option>
									</c:forEach>
								</select>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-source" class="col-sm-2 control-label">线索来源</label>
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
									<textarea class="form-control" rows="3" id="edit-contactSummary">这个线索即将被转换</textarea>
								</div>
							</div>
							<div class="form-group">
								<label for="edit-nextContactTime" class="col-sm-2 control-label">下次联系时间</label>
								<div class="col-sm-10" style="width: 300px;">
									<input type="text" class="form-control" id="edit-nextContactTime" >
								</div>
							</div>
						</div>
						
						<div style="height: 1px; width: 103%; background-color: #D5D5D5; left: -13px; position: relative; top : 10px;"></div>

                        <div style="position: relative;top: 20px;">
                            <div class="form-group">
                                <label for="edit-address" class="col-sm-2 control-label">详细地址</label>
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
				<h3>线索列表</h3>
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
				      <div class="input-group-addon">公司</div>
				      <input class="form-control" type="text" id="search-company">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">公司座机</div>
				      <input class="form-control" type="text" id="search-phone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索来源</div>
					  <select class="form-control" id="search-source">
						  <option></option>
						  <c:forEach items="${source}" var="s">
							  <option value="${s.value}">${s.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>
				  
				  <br>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text"id="search-owner">
				    </div>
				  </div>
				  
				  
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">手机</div>
				      <input class="form-control" type="text" id="search-mphone">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">线索状态</div>
					  <select class="form-control" id="search-state">
						  <option></option>
						  <c:forEach items="${clueState}" var="c">
							  <option value="${c.value}">${c.text}</option>
						  </c:forEach>
					  </select>
				    </div>
				  </div>

				  <button type="button" id="searchBtn" class="btn btn-default">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 40px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="addBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" id="editBtn" class="btn btn-default" ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button"  id="deleteBtn" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				
				
			</div>
			<div style="position: relative;top: 50px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="qx"/></td>
							<td>名称</td>
							<td>公司</td>
							<td>公司座机</td>
							<td>手机</td>
							<td>线索来源</td>
							<td>所有者</td>
							<td>线索状态</td>
						</tr>
					</thead>
					<tbody id="clueBody">
<%--						<tr>--%>
<%--							<td><input type="checkbox" /></td>--%>
<%--							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='workbench/clue/detail.do?';">李四先生</a></td>--%>
<%--							<td>动力节点</td>--%>
<%--							<td>010-84846003</td>--%>
<%--							<td>12345678901</td>--%>
<%--							<td>广告</td>--%>
<%--							<td>zhangsan</td>--%>
<%--							<td>已联系</td>--%>
<%--						</tr>--%>
<%--                        <tr class="active">--%>
<%--                            <td><input type="checkbox" /></td>--%>
<%--                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">李四先生</a></td>--%>
<%--                            <td>动力节点</td>--%>
<%--                            <td>010-84846003</td>--%>
<%--                            <td>12345678901</td>--%>
<%--                            <td>广告</td>--%>
<%--                            <td>zhangsan</td>--%>
<%--                            <td>已联系</td>--%>
<%--                        </tr>--%>
					</tbody>
				</table>
			</div>
			
			<div style="height: 50px; position: relative;top: 60px;">
					<div id="cluePage"></div>
			</div>
		</div>
		
	</div>
</body>
</html>