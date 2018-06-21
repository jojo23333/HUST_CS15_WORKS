# Generated by Django 2.0.5 on 2018-06-17 18:08

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('oj', '0001_initial'),
    ]

    operations = [
        migrations.AlterField(
            model_name='problem',
            name='std',
            field=models.FileField(upload_to='./stds/'),
        ),
        migrations.AlterField(
            model_name='submission',
            name='judge_time',
            field=models.DateField(auto_now=True),
        ),
        migrations.AlterField(
            model_name='user',
            name='creation_date',
            field=models.DateField(auto_now_add=True),
        ),
    ]
