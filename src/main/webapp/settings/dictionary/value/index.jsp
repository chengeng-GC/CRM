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
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<%--分页控件--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>

	<script type="text/javascript">
		$(function () {
			pageList(1,10);

			//为查询按钮添加绑定事件，触发pageList方法
			$("#searchBtn").click(function () {
				//将搜索框汇中的信息保存到隐藏域中，防止其他途径触发pageList方法用未点击查询的搜索框信息查询
				$("#hidden-typeCode").val($.trim($("#search-typeCode").val()));
				//应该回到第一页，维持每页展现的记录数
				pageList(1,$("#DicValuePage").bs_pagination('getOption','rowsPerPage'));
			})
		});

		function pageList(pageNo,pageSize){
			//消除复选框的√
			$("#qx").prop("checked",false);
			$("#search-typeCode").val($.trim($("#hidden-typeCode").val()));

			$.ajax({
				url:"settings/dic/pageListValue.do",
				data:{
					"pageNo":pageNo,
					"pageSize":pageSize,
					"typeCode":$.trim($("#search-typeCode").val())
				},
				type: "get",
				dataType:"json",
				success:function(data){
					var html="";
					$.each(data.dataList,function (i,n) {
						html += '<tr>';
						html += '<td><input type="checkbox" name="xz" value="'+n.id+'"/></td>';
						html += '<td>'+n.value+'</td>';
						html += '<td>'+n.text+'</td>';
						html += '<td>'+n.orderNo+'</td>';
						html += '<td>'+n.typeCode+'</td>';
						html += '</tr>';
					})
					$("#DicValueBody").html(html);

					//计算总页数
					var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

					//数据处理完毕后，结合分页插件，对前端展现分页相关信息
					$("#DicValuePage").bs_pagination({
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
<input type="hidden" id="hidden-typeCode">
	<div>
		<div style="position: relative; left: 30px; top: -10px;">
			<div class="page-header">
				<h3>字典值列表</h3>
			</div>
		</div>
	</div>
	<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px;">
		<div class="btn-toolbar" role="toolbar" style="height: 80px;">
			<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">

				<div class="form-group">
					<div class="input-group">
						<div class="input-group-addon">字典类型编码</div>
						<select class="form-control" id="search-typeCode">
							<option></option>
							<c:forEach items="${typeCode}" var="s">
								<option value="${s}">${s}</option>
							</c:forEach>
						</select>
					</div>
				</div>

				<button type="button" id="searchBtn" class="btn btn-default">查询</button>

			</form>
		</div>
		<div class="btn-group" style="position: relative; top: 18%;">
		  <button type="button" class="btn btn-primary" onclick="window.location.href='settings/dictionary/value/save.html'"><span class="glyphicon glyphicon-plus"></span> 创建</button>
		  <button type="button" class="btn btn-default" onclick="window.location.href='settings/dictionary/value/edit.html'"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
		  <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	<div style="position: relative; left: 30px; top: 20px;">
		<table class="table table-hover">
			<thead>
				<tr style="color: #B3B3B3;">
					<td><input type="checkbox" /></td>
					<td>字典值</td>
					<td>文本</td>
					<td>排序号</td>
					<td>字典类型编码</td>
				</tr>
			</thead>
			<tbody id="DicValueBody">
				<%--<tr class="active">
					<td><input type="checkbox" /></td>
					<td>1</td>
					<td>m</td>
					<td>男</td>
					<td>1</td>
					<td>sex</td>
				</tr>
				<tr>
					<td><input type="checkbox" /></td>
					<td>2</td>
					<td>f</td>
					<td>女</td>
					<td>2</td>
					<td>sex</td>
				</tr>
				<tr class="active">
					<td><input type="checkbox" /></td>
					<td>3</td>
					<td>1</td>
					<td>一级部门</td>
					<td>1</td>
					<td>orgType</td>
				</tr>
				<tr>
					<td><input type="checkbox" /></td>
					<td>4</td>
					<td>2</td>
					<td>二级部门</td>
					<td>2</td>
					<td>orgType</td>
				</tr>
				<tr class="active">
					<td><input type="checkbox" /></td>
					<td>5</td>
					<td>3</td>
					<td>三级部门</td>
					<td>3</td>
					<td>orgType</td>
				</tr>--%>
			</tbody>
		</table>
	</div>

	<div style="height: 50px; position: relative;top: 30px;">

		<div id="DicValuePage">

		</div>

	</div>
</body>
</html>