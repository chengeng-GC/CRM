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


		//页面加载完毕后，展现该市场活动关联的备注信息列表
		showRemarkList();

        $("#saveRemarkBtn").click(function () {
            var noteContent=$.trim($("#remark").val());
            if (noteContent!=null&&noteContent!=""){
            //执行备注的添加操作
            $.ajax({
                url:"workbench/activity/saveRemark.do",
                data:{
                    "noteContent":$.trim($("#remark").val()),
                    "activityId":"${a.id}"
                },
                type: "post",
                dataType:"json",
                success:function(data){
                    //传回success和一个ActivityRemark ar
                    if (data.success){
                        //将textarea文本域中的信息清空
                        $("#remark").val("");
                        //执行网页上备注添加(before)
                        var html="";
                        html = remarkHtml(html,data.ar);
                        $("#remarkDiv").before(html);
                    }else {
                        alert("保存备注失败")
                    }
                }
            })
            }else {
                alert("内容不能为空");
            }
        })

        $("#updateRemarkBtn").click(function () {
            var noteContent=$.trim($("#noteContent").val());
            var id=$("#remarkId").val()
            //文本域中内容不能为空
            if (noteContent==null ||noteContent==""){
                alert("内容不能为空");
            }else if (noteContent==$("#remarkNoteContent").val()){
                alert("该内容无需修改");
            } else{
                $.ajax({
                    url:"workbench/activity/updateRemark.do",
                    data:{
                        "id":id,
                        "noteContent":noteContent
                    },
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        //success  ActivityRemark
                        if (data.success){
                            //更新div中相应信息
                            $("#"+id).find("h5").html(noteContent)
                            $("#"+id).find("small").html(data.ar.editTime+"由"+data.ar.editBy);
                            //关闭模态窗口
                            $("#editRemarkModal").modal("hide");
                        }else {
                            alert("修改备注失败");
                        }
                    }
                })
            }
        })
        //为编辑按钮绑定事件，打开编辑市场活动模态窗口
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
                    $("#edit-owner").html(html);
                    //当前用户作为下拉列表的默认选项
                    //在js中使用el表达式，el表达式一定要套用在字符串中
                    $("#edit-owner").val("${user.id}");
                    //所有者下拉框处理完毕后,展现模态窗口
                    $("#editActivityModal").modal("show");
                }
            })
        })

        //为更新按钮绑定点击事件,执行更新操作
        $("#updateBtn").click(function () {
            $.ajax({
                url:"workbench/activity/update.do",
                data:{
                    "id":"${a.id}",
                    "owner":$.trim($("#edit-owner").val()),
                    "name":$.trim($("#edit-name").val()),
                    "startDate":$.trim($("#edit-startDate").val()),
                    "endDate":$.trim($("#edit-endDate").val()),
                    "cost":$.trim($("#edit-cost").val()),
                    "description":$.trim($("#edit-description").val())
                },
                type: "post",
                dataType:"json",
                success:function(data){
                    if (data.success){
                        //更新成功后,刷新下页面
                        //当前页数不变，每页的条数不变
                       window.location.href="workbench/activity/detail.do?id=${a.id}";
                    }else {
                        alert("更新市场活动失败");
                    }
                    //关闭模态窗口
                    $("#editActivityModal").modal("hide");
                }
            })
        })
        //为删除按钮绑定事件，执行删除操作
        $("#deleteBtn").click(function () {
            $.ajax({
                url:"workbench/activity/delete.do",
                data:{
                    "id":"${a.id}"
                },
                type: "post",
                dataType:"json",
                success:function(data){
                    if (data.success){
                        //删除成功后,回到市场活动index页面
                        window.location.href="workbench/activity/index.jsp";
                    }else {
                        alert("删除市场活动失败");
                    }
                }
            })
        })

	});

	function showRemarkList() {
		$.ajax({
			url:"workbench/activity/getRemarkListByAid.do",
			data:{
				"activityId":"${a.id}"
			},
			type: "get",
			dataType:"json",
			success:function(data){
			    //返回一个List<ActivityRemark>
				var html="";
				$.each(data,function (i,n) {
				html=remarkHtml(html,n);
				})
                $("#remarkDiv").before(html);
			}
		})
	}

	function deleteRemark(id) {
        $.ajax({
            url:"workbench/activity/deleteRemark.do",
            data:{
                "id":id
            },
            type: "post",
            dataType:"json",
            success:function(data){
                if (data.success){
                    //这种做法不行，使用的是before，会继续追加
                    //showRemarkList();
                    //找到需要删除记录的div,将div移除掉
                    $("#"+id).remove();
                }else {
                    alert("删除备注失败");
                }
            }
        })
    }
    function remarkHtml(html,n) {
        html += '<div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
        html += '<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
        html += '<div style="position: relative; top: -40px; left: 40px;" >';
        html += '<h5>'+n.noteContent+'</h5>';
        html += '<font color="gray">市场活动</font> <font color="gray">-</font> <b>${a.name}</b> <small style="color: gray;"> '+(n.editFlag==0?n.createTime:n.editTime)+' 由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
        html += '<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
        html += '<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
        html += '&nbsp;&nbsp;&nbsp;&nbsp;';
        html += '<a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')" ><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
        html += '</div>';
        html += '</div>';
        html += '</div>';
        return html;
    }
    function editRemark(id) {
	    //获取指定id对应的noteContent信息，并赋予给修改备注模态窗口中的内容文本域和隐藏域
        var noteContent=$("#"+id).find("h5").html();
        $("#noteContent").val(noteContent);
        $("#remarkNoteContent").val(noteContent);
        //将id赋予给修改备注模态窗口中的隐藏域
        $("#remarkId").val(id);
	    $("#editRemarkModal").modal("show");
    }
</script>

</head>
<body>
	
	<!-- 修改市场活动备注的模态窗口 -->
	<div class="modal fade" id="editRemarkModal" role="dialog">
		<%-- 备注的id --%>
		<input type="hidden" id="remarkId">
<%--            备注的notecontent--%>
        <input type="hidden" id="remarkNoteContent">
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

    <!-- 修改市场活动的模态窗口 -->
    <div class="modal fade" id="editActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">修改市场活动</h4>
                </div>
                <div class="modal-body">

                    <form class="form-horizontal" role="form">

                        <div class="form-group">
                            <label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <select class="form-control" id="edit-owner">

                                </select>
                            </div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-name" value="${a.name}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-startDate" value="${a.startDate}" readonly>
                            </div>
                            <label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control time" id="edit-endDate" value="${a.endDate}" readonly>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-cost" value="${a.cost}">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="edit-describe" class="col-sm-2 control-label">描述</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-description">${a.description}</textarea>
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
			<h3>市场活动-${a.name} <small>${a.startDate} ~ ${a.endDate}</small></h3>
		</div>
		<div style="position: relative; height: 50px; width: 250px;  top: -72px; left: 700px;">
			<button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑</button>
			<button type="button" id="deleteBtn" class="btn btn-danger"><span class="glyphicon glyphicon-minus"></span> 删除</button>
		</div>
	</div>
	
	<!-- 详细信息 -->
	<div style="position: relative; top: -70px;">
		<div style="position: relative; left: 40px; height: 30px;">
			<div style="width: 300px; color: gray;">所有者</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.owner}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${a.name}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>

		<div style="position: relative; left: 40px; height: 30px; top: 10px;">
			<div style="width: 300px; color: gray;">开始日期</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.startDate}</b></div>
			<div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">结束日期</div>
			<div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${a.endDate}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 20px;">
			<div style="width: 300px; color: gray;">成本</div>
			<div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${a.cost}</b></div>
			<div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 30px;">
			<div style="width: 300px; color: gray;">创建者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${a.createBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${a.createTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 40px;">
			<div style="width: 300px; color: gray;">修改者</div>
			<div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${a.editBy}&nbsp;&nbsp;</b><small style="font-size: 10px; color: gray;">${a.editTime}</small></div>
			<div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
		<div style="position: relative; left: 40px; height: 30px; top: 50px;">
			<div style="width: 300px; color: gray;">描述</div>
			<div style="width: 630px;position: relative; left: 200px; top: -20px;">
				<b>
					${a.description}
				</b>
			</div>
			<div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
		</div>
	</div>
	
	<!-- 备注 -->
	<div id="remarkBody" style="position: relative; top: 30px; left: 40px;">
		<div class="page-header">
			<h4>备注</h4>
		</div>
		
		<!-- 备注1 -->
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>哎呦！</h5>--%>
<%--				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:10:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>

		<!-- 备注2 -->
<%--		<div class="remarkDiv" style="height: 60px;">--%>
<%--			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--			<div style="position: relative; top: -40px; left: 40px;" >--%>
<%--				<h5>呵呵！</h5>--%>
<%--				<font color="gray">市场活动</font> <font color="gray">-</font> <b>发传单</b> <small style="color: gray;"> 2017-01-22 10:20:10 由zhangsan</small>--%>
<%--				<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--					&nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--					<a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--				</div>--%>
<%--			</div>--%>
<%--		</div>--%>
		<div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
			<form role="form" style="position: relative;top: 10px; left: 10px;">
				<textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"  placeholder="添加备注..."></textarea>
				<p id="cancelAndSaveBtn" style="position: relative;left: 737px; top: 10px; display: none;">
					<button id="cancelBtn" type="button" class="btn btn-default">取消</button>
					<button type="button" id="saveRemarkBtn" class="btn btn-primary">保存</button>
				</p>
			</form>
		</div>
	</div>
	<div style="height: 200px;"></div>
</body>
</html>