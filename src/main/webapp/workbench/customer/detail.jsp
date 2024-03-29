<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath();
%>
<!DOCTYPE html>
<html>
<head>
    <base href="<%=basePath%>/crm">
    <meta charset="UTF-8"http-equiv="Content-Security-Policy" content="upgrade-insecure-requests">

    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet"/>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <%--	时间选择器（日历）控件--%>
    <link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <%--	自动补全插件--%>
    <script type="text/javascript" src="jquery/bs_typeahead/bootstrap3-typeahead.min.js"></script>

    <script type="text/javascript">

        //默认情况下取消和保存按钮是隐藏的
        var cancelAndSaveBtnDefault = true;

        $(function () {
            $("#remark").focus(function () {
                if (cancelAndSaveBtnDefault) {
                    //设置remarkDiv的高度为130px
                    $("#remarkDiv").css("height", "130px");
                    //显示
                    $("#cancelAndSaveBtn").show("2000");
                    cancelAndSaveBtnDefault = false;
                }
            });

            $("#cancelBtn").click(function () {
                //显示
                $("#cancelAndSaveBtn").hide();
                //设置remarkDiv的高度为130px
                $("#remarkDiv").css("height", "90px");
                cancelAndSaveBtnDefault = true;
            });

            $(".remarkDiv").mouseover(function () {
                $(this).children("div").children("div").show();
            });

            $(".remarkDiv").mouseout(function () {
                $(this).children("div").children("div").hide();
            });

            $(".myHref").mouseover(function () {
                $(this).children("span").css("color", "red");
            });

            $(".myHref").mouseout(function () {
                $(this).children("span").css("color", "#E6E6E6");
            });
            $("#remarkBody").on("mouseover",".remarkDiv",function(){
                $(this).children("div").children("div").show();
            })
            $("#remarkBody").on("mouseout",".remarkDiv",function(){
                $(this).children("div").children("div").hide();
            })
                //自动补全插件
            $("#create-customerName").typeahead({
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

            //页面加载完毕展示备注列表
            showRemarkList();
            showTranList();
            showContactsList();
            //为备注保存按钮添加事件，执行添加操作
            $("#saveRemarkBtn").click(function () {
                var noteContent=$.trim($("#remark").val());
                if (noteContent!=null&&noteContent!=""){
                    //执行备注的添加操作
                    $.ajax({
                        url:"workbench/customer/saveRemark.do",
                        data:{
                            "noteContent":$.trim($("#remark").val()),
                            "customerId":"${c.id}"
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
                        url:"workbench/customer/updateRemark.do",
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

            //为修改按钮绑定事件，打开修改模态窗口
            $("#editBtn").click(function () {
                    var id="${c.id}";
                    $.ajax({
                        url:"workbench/customer/getUserListAndCustomer.do",
                        data:{"id":id
                        },
                        type: "get",
                        dataType:"json",
                        success:function(data){
                            //用户列表uList
                            //线索单条 c
                            var html="";
                            $.each(data.uList,function (i,n) {
                                html +="<option value='"+n.id+"'>"+n.name+"</option>";
                            })
                            $("#edit-owner").html(html);


                            //处理单条customer
                            $("#hidden-edit-id").val(data.c.id);
                            $("#edit-name").val(data.c.name);
                            $("#edit-owner").val(data.c.owner);
                            $("#edit-website").val(data.c.website);
                            $("#edit-phone").val(data.c.phone);
                            $("#edit-contactSummary").val(data.c.contactSummary);
                            $("#edit-nextContactTime").val(data.c.nextContactTime);
                            $("#edit-description").val(data.c.description);
                            $("#edit-address").val(data.c.address);

                            //处理完毕后,展现模态窗口
                            $("#editCustomerModal").modal("show");
                        }
                    })
            })

            //为更新客户按钮绑定事件，执行更新操作
            $("#updateBtn").click(function () {
                var name=$.trim($("#edit-name").val());
                if (name==null||name=="") {
                    alert("名称不能为空");
                    return ;
                }
                $.ajax({
                    url:"workbench/customer/update.do",
                    data:{
                        "id":$.trim($("#hidden-edit-id").val()),
                        "owner":$.trim($("#edit-owner").val()),
                        "name":name,
                        "website":$.trim($("#edit-website").val()),
                        "phone":$.trim($("#edit-phone").val()),
                        "contactSummary":$.trim($("#edit-contactSummary").val()),
                        "nextContactTime":$.trim($("#edit-nextContactTime").val()),
                        "description":$.trim($("#edit-description").val()),
                        "address":$.trim($("#edit-address").val())
                    },
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        if (data.success){
                            //更新成功后，刷新下页面
                            window.location.href="workbench/customer/detail.do?id=${c.id}"
                        }else {
                            alert("更新客户失败");
                        }
                        //关闭模态窗口
                        $("#editCustomerModal").modal("hide");
                    }
                })
            })

            //为删除客户按钮绑定事件,执行线索删除操作
            $("#deleteBtn").click(function () {

                //给用户一个提示，避免误删
                if (confirm("确定删除客户吗？")){
                    $.ajax({
                        url:"workbench/customer/delete.do",
                        data:{"id":"${c.id}"},
                        type: "post",
                        dataType:"json",
                        success:function(data){
                            if (data.success){
                                //删除成功后回到index页面
                                window.location.href="workbench/customer/index.jsp";
                            }else {
                                alert("删除客户失败");
                            }
                        }
                    })
                }
            })

//为创建按钮添加绑定事件，打开添加操作的模态窗口
            $("#createContactsBtn").click(function () {
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
                    url : "workbench/customer/getUserList.do",
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
            $("#saveContactsBtn").click(function () {
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
                            window.location.href="workbench/customer/detail.do?id=${c.id}";
                        }
                    }
                })
            })


        });



        function showContactsList() {
            $.ajax({
                url: "workbench/customer/showContactsListByCid.do",
                data: {
                    "customerId": "${c.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    // aList
                    var html = "";
                    $.each(data, function (i, n) {
                        html += ' <tr>';
                        html += ' <td><a href="workbench/contacts/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.fullname+'</a></td>';
                        html += ' <td>'+n.email+'</td>';
                        html += ' <td>'+n.mphone+'</td>';
                        html += ' <td><a href="javascript:void(0);" onclick="deleteContacts(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
                        html += ' </tr>';

                    })
                    $("#contactsBody").html(html);
                }
            })
        }
        function deleteContacts(id) {
            //给用户一个提示，避免误删
            if (confirm("确定删除记录吗？")){
                $.ajax({
                    url:"workbench/contacts/delete.do",
                    data:{"id":id},
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        if (data.success){
                            window.location.href="workbench/customer/detail.do?id=${c.id}";
                        }else {
                            alert("删除联系人失败");
                        }
                    }
                })
            }
        }


        function showTranList() {
            $.ajax({
                url: "workbench/customer/showTranListByCid.do",
                data: {
                    "customerId": "${c.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    // aList
                    var html = "";
                    $.each(data, function (i, n) {
                        html += ' <tr>';
                        html += ' <td><a href="workbench/transaction/detail.do?id='+n.id+'" style="text-decoration: none;">'+n.name+'</a></td>';
                        html += ' <td>'+n.money+'</td>';
                        html += ' <td>'+n.stage+'</td>';
                        html += ' <td>'+n.possibility+'</td>';
                        html += ' <td>'+n.expectedDate+'</td>';
                        html += ' <td>'+n.type+'</td>';
                        html += ' <td><a href="javascript:void(0);" onclick="deleteTran(\''+n.id+'\')" style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>';
                        html += ' </tr>';
                    })
                    $("#tranBody").html(html);
                }
            })
        }

        function deleteTran(id) {
            //给用户一个提示，避免误删
            if (confirm("确定删除记录吗？")){
                $.ajax({
                    url:"workbench/transaction/delete.do",
                    data:{"id":id},
                    type: "post",
                    dataType:"json",
                    success:function(data){
                        if (data.success){
                            window.location.href="workbench/customer/detail.do?id=${c.id}";
                        }else {
                            alert("删除交易失败");
                        }
                    }
                })
            }
        }
        function showRemarkList() {
            $.ajax({
                url: "workbench/customer/showRemarkListByCid.do",
                data: {
                    "customerId": "${c.id}"
                },
                type: "get",
                dataType: "json",
                success: function (data) {
                    //返回一个List<CustomerRemark>
                    var html = "";
                    $.each(data, function (i, n) {
                        html += ' <div id="'+n.id+'" class="remarkDiv" style="height: 60px;">';
                        html += '			<img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">';
                        html += ' 			<div style="position: relative; top: -40px; left: 40px;" >';
                        html += '			<h5>'+n.noteContent+'</h5>';
                        html += ' 	<font color="gray">客户</font> <font color="gray">-</font> <b>${c.name}-${c.website}</b> <small style="color: gray;">'+(n.editFlag==0?n.createTime:n.editTime)+'由'+(n.editFlag==0?n.createBy:n.editBy)+'</small>';
                        html += ' 	<div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">';
                        html += ' 			<a class="myHref" href="javascript:void(0);" onclick="editRemark(\''+n.id+'\')" ><span class="glyphicon glyphicon-edit" style="font-size: 20px; color: #FF0000;"></span></a>';
                        html += ' 	&nbsp;&nbsp;&nbsp;&nbsp;';
                        html += ' <a class="myHref" href="javascript:void(0);" onclick="deleteRemark(\''+n.id+'\')"><span class="glyphicon glyphicon-remove" style="font-size: 20px; color: #FF0000;"></span></a>';
                        html += ' 	</div>';
                        html += ' 	</div>';
                        html += ' 	</div>';
                    })
                    $("#remarkHtml").html(html);
                }
            })
        }

        function deleteRemark(id) {
            $.ajax({
                url:"workbench/customer/deleteRemark.do",
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
                <button type="button" class="btn btn-primary" id="saveContactsBtn">保存</button>
            </div>
        </div>
    </div>
</div>
<!-- 修改客户的模态窗口 -->
<div class="modal fade" id="editCustomerModal" role="dialog">
    <div class="modal-dialog" role="document" style="width: 85%;">
        <div class="modal-content">
            <div class="modal-header">
                <button type="button" class="close" data-dismiss="modal">
                    <span aria-hidden="true">×</span>
                </button>
                <h4 class="modal-title" id="myModalLabel">修改客户</h4>
            </div>
            <div class="modal-body">
                <form class="form-horizontal" role="form">
                    <input type="hidden" id="hidden-edit-id">
                    <div class="form-group">
                        <label for="edit-customerOwner" class="col-sm-2 control-label">所有者<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <select class="form-control" id="edit-owner">
                            </select>
                        </div>
                        <label for="edit-customerName" class="col-sm-2 control-label">名称<span
                                style="font-size: 15px; color: red;">*</span></label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-name" >
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="edit-website" class="col-sm-2 control-label">公司网站</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-website">
                        </div>
                        <label for="edit-phone" class="col-sm-2 control-label">公司座机</label>
                        <div class="col-sm-10" style="width: 300px;">
                            <input type="text" class="form-control" id="edit-phone" >
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
                            <label for="create-contactSummary1" class="col-sm-2 control-label">联系纪要</label>
                            <div class="col-sm-10" style="width: 81%;">
                                <textarea class="form-control" rows="3" id="edit-contactSummary"></textarea>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="create-nextContactTime2" class="col-sm-2 control-label">下次联系时间</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-nextContactTime">
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

<!-- 返回按钮 -->
<div style="position: relative; top: 35px; left: 10px;">
    <a href="javascript:void(0);" onclick="window.history.back();"><span class="glyphicon glyphicon-arrow-left"
                                                                         style="font-size: 20px; color: #DDDDDD"></span></a>
</div>

<!-- 大标题 -->
<div style="position: relative; left: 40px; top: -30px;">
    <div class="page-header">
        <h3>${c.name} <small><a href="${c.website}" target="_blank">${c.website}</a></small></h3>
    </div>
    <div style="position: relative; height: 50px; width: 500px;  top: -72px; left: 700px;">
        <button type="button" class="btn btn-default" id="editBtn"><span class="glyphicon glyphicon-edit"></span> 编辑
        </button>
        <button type="button" class="btn btn-danger" id="deleteBtn"><span class="glyphicon glyphicon-minus"></span> 删除
        </button>
    </div>
</div>

<!-- 详细信息 -->
<div style="position: relative; top: -70px;">
    <div style="position: relative; left: 40px; height: 30px;">
        <div style="width: 300px; color: gray;">所有者</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.owner}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">名称</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.name}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 10px;">
        <div style="width: 300px; color: gray;">公司网站</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.website}</b></div>
        <div style="width: 300px;position: relative; left: 450px; top: -40px; color: gray;">公司座机</div>
        <div style="width: 300px;position: relative; left: 650px; top: -60px;"><b>${c.phone}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px;"></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -60px; left: 450px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 20px;">
        <div style="width: 300px; color: gray;">创建者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.createBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${c.createTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 30px;">
        <div style="width: 300px; color: gray;">修改者</div>
        <div style="width: 500px;position: relative; left: 200px; top: -20px;"><b>${c.editBy}&nbsp;&nbsp;</b><small
                style="font-size: 10px; color: gray;">${c.editTime}</small></div>
        <div style="height: 1px; width: 550px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 40px;">
        <div style="width: 300px; color: gray;">联系纪要</div>
        <div style="width: 630px;position: relative; left: 200px; top: -20px;">
            <b>
                ${c.contactSummary}
            </b>
        </div>
        <div style="height: 1px; width: 850px; background: #D5D5D5; position: relative; top: -20px;"></div>
    </div>
    <div style="position: relative; left: 40px; height: 30px; top: 50px;">
        <div style="width: 300px; color: gray;">下次联系时间</div>
        <div style="width: 300px;position: relative; left: 200px; top: -20px;"><b>${c.nextContactTime}</b></div>
        <div style="height: 1px; width: 400px; background: #D5D5D5; position: relative; top: -20px; "></div>
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
<div id="remarkBody" style="position: relative; top: 10px; left: 40px;">
    <div class="page-header">
        <h4>备注</h4>
    </div>

<%--    <!-- 备注1 -->--%>
<%--    <div class="remarkDiv" style="height: 60px;">--%>
<%--        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--        <div style="position: relative; top: -40px; left: 40px;">--%>
<%--            <h5>哎呦！</h5>--%>
<%--            <font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;">--%>
<%--            2017-01-22 10:10:10 由zhangsan</small>--%>
<%--            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"--%>
<%--                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--                &nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"--%>
<%--                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>

<%--    <!-- 备注2 -->--%>
<%--    <div class="remarkDiv" style="height: 60px;">--%>
<%--        <img title="zhangsan" src="image/user-thumbnail.png" style="width: 30px; height:30px;">--%>
<%--        <div style="position: relative; top: -40px; left: 40px;">--%>
<%--            <h5>呵呵！</h5>--%>
<%--            <font color="gray">联系人</font> <font color="gray">-</font> <b>李四先生-北京动力节点</b> <small style="color: gray;">--%>
<%--            2017-01-22 10:20:10 由zhangsan</small>--%>
<%--            <div style="position: relative; left: 500px; top: -30px; height: 30px; width: 100px; display: none;">--%>
<%--                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-edit"--%>
<%--                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--                &nbsp;&nbsp;&nbsp;&nbsp;--%>
<%--                <a class="myHref" href="javascript:void(0);"><span class="glyphicon glyphicon-remove"--%>
<%--                                                                   style="font-size: 20px; color: #E6E6E6;"></span></a>--%>
<%--            </div>--%>
<%--        </div>--%>
<%--    </div>--%>

    <div id="remarkHtml"></div>
    <div id="remarkDiv" style="background-color: #E6E6E6; width: 870px; height: 90px;">
        <form role="form" style="position: relative;top: 10px; left: 10px;">
            <textarea id="remark" class="form-control" style="width: 850px; resize : none;" rows="2"
                      placeholder="添加备注..."></textarea>
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
            <table id="activityTable2" class="table table-hover" style="width: 900px;">
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
                <tbody id="tranBody">
<%--                <tr>--%>
<%--                    <td><a href="workbench/transaction/detail.jsp" style="text-decoration: none;">动力节点-交易01</a></td>--%>
<%--                    <td>5,000</td>--%>
<%--                    <td>谈判/复审</td>--%>
<%--                    <td>90</td>--%>
<%--                    <td>2017-02-07</td>--%>
<%--                    <td>新业务</td>--%>
<%--                    <td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeTransactionModal"--%>
<%--                           style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>--%>
<%--                </tr>--%>
                </tbody>
            </table>
        </div>

        <div>
            <a href="workbench/transaction/save.do" style="text-decoration: none;"><span
                    class="glyphicon glyphicon-plus"></span>新建交易</a>
        </div>
    </div>
</div>

<!-- 联系人 -->
<div>
    <div style="position: relative; top: 20px; left: 40px;">
        <div class="page-header">
            <h4>联系人</h4>
        </div>
        <div style="position: relative;top: 0px;">
            <table id="activityTable" class="table table-hover" style="width: 900px;">
                <thead>
                <tr style="color: #B3B3B3;">
                    <td>名称</td>
                    <td>邮箱</td>
                    <td>手机</td>
                    <td></td>
                </tr>
                </thead>
                <tbody id="contactsBody">
<%--                <tr>--%>
<%--                    <td><a href="workbench/contacts/detail.jsp" style="text-decoration: none;">李四</a></td>--%>
<%--                    <td>lisi@bjpowernode.com</td>--%>
<%--                    <td>13543645364</td>--%>
<%--                    <td><a href="javascript:void(0);" data-toggle="modal" data-target="#removeContactsModal"--%>
<%--                           style="text-decoration: none;"><span class="glyphicon glyphicon-remove"></span>删除</a></td>--%>
<%--                </tr>--%>
                </tbody>
            </table>
        </div>

        <div>
            <a href="javascript:void(0);" id="createContactsBtn"
               style="text-decoration: none;"><span class="glyphicon glyphicon-plus"></span>新建联系人</a>
        </div>
    </div>
</div>

<div style="height: 200px;"></div>
</body>
</html>