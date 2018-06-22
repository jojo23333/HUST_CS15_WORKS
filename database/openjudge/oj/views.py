import markdown, pytz
from random import randint
from datetime import datetime
from .models import Problem, Submission, Contest, UserProfile
from .forms import loginForm, registerForm, submitForm

from django.views import generic, View
from django.shortcuts import render, redirect, get_object_or_404
from django.core.paginator import Paginator
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
from django.contrib.auth.mixins import LoginRequiredMixin
from django.core.exceptions import ObjectDoesNotExist

# Create your views here.


def logoutView(request):
    logout(request)
    return redirect('/')


class indexView(View):
    def get(self, request):
        return render(request, "index.html")



class loginView(View):
    def get(self, request, *args, **kwargs):
        # login page
        if request.user.is_authenticated:
            return redirect("/problems/")
        else:
            return render(request, 'login.html')

    def post(self, request, *args, **kwargs):
        # login
        form = loginForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            password = form.cleaned_data['password']
            user = authenticate(request, username=username, password=password)
            if user is not None:
                login(request, user)
                # Redirect to main page with a success message.
                return redirect("/?login=success")
            else:
                print("Fail!")
                # Return an 'invalid login' error message.
                message = "用户名或密码错误"
                return render(request, 'login.html', {'msg': message})
        else:
            message = "用户名或者密码字段不合法！"
            return render(request, 'login.html', {'msg': message})



class registerView(View):
    def get(self, request, *args, **kwargs):
        # if logined redirect to problem page
        if request.user.is_authenticated:
            return redirect("/problems/")
        else:
            return render(request, 'register.html')

    def post(self, request, *args, **kwargs):
        form = registerForm(request.POST)
        if form.is_valid():
            username = form.cleaned_data['username']
            email = form.cleaned_data['email']
            password = form.cleaned_data['password']
            repeat_password = form.cleaned_data['repeat_password']

            if repeat_password != password:
                message = "密码不一致！"
                return render(request, 'register.html', {"msg": message})
            elif User.objects.filter(username=username):
                # user with username already exist
                message = "用户名：" + username + " 已存在. 请选择其它用户名！"
                return render(request, 'register.html', {"msg": message})
            else:
                # create new user & user profile
                print(username,",",password)
                user = User.objects.create_user(username=username, email=email, password=password)
                user_profile = UserProfile.objects.create(user=user, is_super_user=False)
                return redirect("/login/?user="+username)
        else:
            message = "字段不合法"
            return render(request, 'register.html', {"msg": message})



class problemListView(View):
    page_size = 10
    def get(self, request, *args, **kwargs):
        # user = request.user.username
        problem_list = Problem.objects.order_by('pid')

        paginator = Paginator(problem_list, self.page_size)
        last_page = (len(problem_list) - 1 )/ self.page_size + 1
        try:
            page = int(request.GET.get("page"))
            show_list = paginator.page(page)
        except Exception:
            page = 1
            show_list = paginator.page(1)
        # extract info for every problem
        for problem in show_list:
            total_submit = Submission.objects.filter(problem=problem)
            ac_submit = total_submit.filter(status='AC')
            if len(total_submit) == 0:
                problem.ac_rate = 0
            else:
                problem.ac_rate = float(len(ac_submit))*100.0/len(total_submit)
            problem.total = len(total_submit)

        return render(request, 'problemList.html', {"page": page, "show_pages": range(page-3, page+3),\
                                                      "last_page": last_page, "list": show_list})



class problemDetailView(generic.DetailView):
    model = Problem
    template_name = "problemDetail.html"
    context_object_name = 'problem'

    def get_object(self, queryset=None):
        obj = super(problemDetailView, self).get_object()
        obj.description = markdown.markdown(obj.description)
        return obj



# submit view login required
class submitView(LoginRequiredMixin, View):
    login_url = '/login'

    def get(self, request, *args, **kwargs):
        return render(request, 'submit.html', kwargs)

    def post(self, request, *args, **kwargs):
        form = submitForm(request.POST)
        if form.is_valid():
            pid = form.cleaned_data['pid']
            language = form.cleaned_data['language']
            source = form.cleaned_data['source']
            try:
                problem = Problem.objects.get(pid=pid)
                # Todo: add judge_backend
                x = ["AC", "WA", "TLE", "MLE"][randint(0,3)]
                new_submit = Submission.objects.create(user=request.user, problem=problem, source=source, language=language, status=x)
                return redirect('/submissions/'+ str(new_submit.id) + '?submit=success')
            except ObjectDoesNotExist:
                return render(request, 'submit.html', {'msg': '指定题号不存在！"'})
        else:
            return render(request, 'submit.html', {'msg' : '表单不合法'})



class submissionListView(View):
    page_size = 10

    def get(self, request, *args, **kwargs):
        # user = request.GET.get('user')

        submission_list = Submission.objects.order_by('-submit_time')
        paginator = Paginator(submission_list, self.page_size)
        last_page = (len(submission_list) - 1) / self.page_size + 1
        try:
            page = int(request.GET.get("page"))
            show_list = paginator.page(page)
        except Exception:
            page = 1
            show_list = paginator.page(1)

        for obj in show_list:
            obj.status = obj.get_status()
            obj.submit_time = obj.submit_time.strftime('%Y-%m-%d %H:%M:%S')

        return render(request, 'submissionList.html', {'page': page, 'last_page': last_page,\
                                                    "show_pages": range(page-3,page+3), "list":show_list})




class submissionDetailView(LoginRequiredMixin, generic.DetailView):
    model = Submission
    template_name = 'submissionDetail.html'
    context_object_name = 'submit'
    login_url = '/login'

    def get_object(self, queryset=None):
        obj = super(submissionDetailView, self).get_object()
        obj.status = obj.get_status()
        obj.submit_time = obj.submit_time.strftime('%Y-%m-%d %H:%M:%S')
        return obj



class contestListView(View):
    page_size = 10

    def get(self, request, *args, **kwargs):
        contest_list = Contest.objects.filter()
        paginator = Paginator(contest_list, self.page_size)
        last_page = (len(contest_list) - 1) / self.page_size + 1
        try:
            page = int(request.GET.get("page"))
            show_list = paginator.page(page)
        except Exception:
            page = 1
            show_list = paginator.page(1)

        for contest in show_list:
            tzinfo = contest.start_time.tzinfo
            if datetime.now(tzinfo) < contest.start_time:
                contest.status = 'scheduled'
                contest.status_color = 'info'
            elif datetime.now(tzinfo) > contest.end_time:
                contest.status = 'ended'
                contest.status_color = 'success'
            else:
                contest.status = 'running'
                contest.status_color = 'warning'
            contest.length = "%.2f" % (abs(contest.end_time-contest.start_time).total_seconds() / 3600.0)
            contest.participant_count = len(contest.submission_set.all().values_list('user', flat=True).distinct())
            contest.start_time = contest.start_time.strftime('%Y-%m-%d %H:%M:%S')


        return render(request, 'contestList.html', {'page': page, 'last_page': last_page,\
                                                    "show_pages": range(page-3,page+3), "list":show_list})


class contestDetailView(LoginRequiredMixin, generic.DetailView):
    model = Contest
    template_name = 'contestDetail.html'
    context_object_name = 'contest'
    login_url = '/login'

    def get_object(self, queryset=None):
        obj = super(contestDetailView, self).get_object()
        obj.problems = obj.problem_set.all().order_by('pid')
        obj.submissions = obj.submission_set.all()

        # problem info
        new_id = ord('A')
        for problem in obj.problems:
            total_submit = obj.submissions.filter(problem=problem)
            ac_submit = total_submit.filter(status='AC')
            problem.accepted = len(ac_submit)
            problem.total = len(total_submit)
            problem.contest_id = chr(new_id)
            problem.description = markdown.markdown(problem.description)
            new_id = new_id + 1

        # submission info
        for submission in obj.submissions:
            submission.status = submission.get_status()
            submission.submit_time = submission.submit_time.strftime('%Y-%m-%d %H:%M:%S')

        # time info
        tzinfo = obj.start_time.tzinfo
        if datetime.now(tzinfo) < obj.start_time:
            obj.status = 'scheduled'
            obj.status_color = 'info'
        elif datetime.now(tzinfo) > obj.end_time:
            obj.status = 'ended'
            obj.status_color = 'success'
        else:
            obj.status = 'running'
            obj.status_color = 'warning'
        obj.start_second = obj.start_time.timestamp()
        obj.end_second = obj.end_time.timestamp()
        obj.length = "%.2f" % (abs(obj.end_time - obj.start_time).total_seconds() / 3600.0)

        # description
        obj.description = markdown.markdown(obj.description)

        # standing
        obj.users = obj.submission_set.all().values_list('user', flat=True).distinct()
        obj.standing = []
        for user_id in obj.users:
            user = User.objects.get(id=user_id)
            # look at all users
            detail = []
            ac_count = 0
            penalty = 0
            user_submit = obj.submission_set.filter(user=user)
            for problem in obj.problems:
                # look at status of each problem
                problem_submit = user_submit.filter(problem=problem).order_by('submit_time')
                ac_submit = problem_submit.filter(status='AC')
                fail_submit = problem_submit.exclude(status='AC')
                if len(problem_submit) == 0:
                    # not yet submit
                    detail.append({"problem": problem, "status": "null", "count" : 0})
                elif len(ac_submit) > 0:
                    # compute penalty for accepted problems
                    ac_count = ac_count + 1
                    fail_before_ac = 0
                    for submit in problem_submit:
                        if submit.status != 'AC':
                            fail_before_ac  = fail_before_ac + 1
                            penalty = penalty + 20
                        else:
                            ac_time = int( abs(submit.submit_time - obj.start_time).total_seconds() / 60 )
                            penalty = penalty + ac_time
                            break
                    detail.append({"problem": problem, "status": "accepted", "count" : fail_before_ac, "time" :ac_time })
                else:
                    # not yet accepted
                    detail.append({"problem": problem, "status": "rejected", "count": len(fail_submit)})

            userinfo = {}
            userinfo["penalty"] = penalty
            userinfo["ac_count"] = ac_count
            userinfo["detail"] = detail
            userinfo["username"] = user.username
            obj.standing.append(userinfo)

        # sort by ac_count desending & penalty ascending
        obj.standing = sorted(obj.standing, key=lambda x: (x['ac_count'], -x['penalty']), reverse=True)
        for i,x in enumerate(obj.standing):
            x["rank"] = i+1

        return obj


class contestSubmitView(LoginRequiredMixin, View):

    def get(self, request, *args, **kwargs):
        contest_id = self.kwargs["contest_id"]
        contest = get_object_or_404(Contest, id=contest_id)
        contest.problems = contest.problem_set.all().order_by('pid')

        new_id = ord('A')
        for problem in contest.problems:
            problem.contest_id = chr(new_id)
            new_id = new_id + 1

        return render(request, 'contestSubmit.html', {"problems": contest.problems})


    def post(self, request, *args, **kwargs):
        contest_id = self.kwargs["contest_id"]
        contest = get_object_or_404(Contest, id=contest_id)
        contest.problems = contest.problem_set.all().order_by('pid')

        new_id = ord('A')
        for problem in contest.problems:
            problem.contest_id = chr(new_id)
            new_id = new_id + 1

        form = submitForm(request.POST)
        if form.is_valid():
            pid = form.cleaned_data['pid']
            language = form.cleaned_data['language']
            source = form.cleaned_data['source']
            try:
                problem = Problem.objects.get(pid=pid)
                # Todo: add judge_backend
                x = ["AC", "WA", "TLE", "MLE"][randint(0, 3)]
                new_submit = Submission.objects.create(user=request.user, problem=problem, source=source,
                                                       language=language, status=x)
                contest.submission_set.add(new_submit)
                return redirect('/submissions/' + str(new_submit.id) + '?submit=success')
            except ObjectDoesNotExist:
                return render(request, 'contestSubmit.html', {'msg': '指定题号不存在！',"problems": contest.problems})
        else:
            print(form.errors)
            return render(request, 'contestSubmit.html', {'msg': '表单不合法', "problems": contest.problems})


# class userProfileView