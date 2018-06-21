from django import forms

class registerForm(forms.Form):
    username = forms.CharField(max_length=50)
    email = forms.EmailField()
    password = forms.CharField(max_length=50)
    repeat_password = forms.CharField(max_length=50)

class loginForm(forms.Form):
    username = forms.CharField(max_length=50)
    password = forms.CharField(max_length=50)

class submitForm(forms.Form):
    pid = forms.IntegerField()
    language = forms.CharField(max_length=10)
    source = forms.CharField(max_length=10000)