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

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<%--分页控件--%>
	<link rel="stylesheet" type="text/css" href="jquery/bs_pagination/jquery.bs_pagination.min.css">
	<script type="text/javascript" src="jquery/bs_pagination/jquery.bs_pagination.min.js"></script>
	<script type="text/javascript" src="jquery/bs_pagination/en.js"></script>
	<script type="text/javascript">
		$(function () {
			pageList(1,10);

		});

		function pageList(pageNo,pageSize){
			//消除复选框的√
			$("#qx").prop("checked",false);

			$.ajax({
				url:"settings/dic/pageListType.do",
				data:{
					"pageNo":pageNo,
					"pageSize":pageSize
				},
				type: "get",
				dataType:"json",
				success:function(data){
					var html="";
					$.each(data.dataList,function (i,n) {
						html += '<tr >';
						html += '<td><input type="checkbox" name="xz" value="'+n.code+'"/></td>';
						html += '<td>'+n.code+'</td>';
						html += '<td>'+n.name+'</td>';
						html += '<td>'+n.description+'</td>';
						html += '</tr>';
					})
					$("#DicTypeBody").html(html);

					//计算总页数
					var totalPages=data.total%pageSize==0?data.total/pageSize:parseInt(data.total/pageSize)+1;

					//数据处理完毕后，结合分页插件，对前端展现分页相关信息
					$("#DicTypePage").bs_pagination({
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

	<div>
		<div style="position: relative; left: 30px; top: -10px;">
			<div class="page-header">
				<h3>字典类型列表</h3>
			</div>
		</div>
	</div>
	<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;left: 30px;">
		<div class="btn-group" style="position: relative; top: 18%;">
		  <button type="button" class="btn btn-primary" onclick="window.location.href='settings/dictionary/type/save.html'"><span class="glyphicon glyphicon-plus"></span> 创建</button>
		  <button type="button" class="btn btn-default" onclick="window.location.href='settings/dictionary/type/edit.html'"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
		  <button type="button" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	<div style="position: relative; left: 30px; top: 20px;">
		<table class="table table-hover">
			<thead>
				<tr style="color: #B3B3B3;">
					<td><input type="checkbox" /></td>
					<td>编码</td>
					<td>名称</td>
					<td>描述</td>
				</tr>
			</thead>
			<tbody id="DicTypeBody">
				<%--<tr class="active">
					<td><input type="checkbox" /></td>
					<td>1</td>
					<td>sex</td>
					<td>性别</td>
					<td>性别包括男和女</td>
				</tr>--%>
			</tbody>
		</table>
	</div>
	<div style="height: 50px; position: relative;top: 30px;">

		<div id="DicTypePage">

		</div>

	</div>

</body>
</html>