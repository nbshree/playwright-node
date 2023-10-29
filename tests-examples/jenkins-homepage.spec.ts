import { test, expect } from '@playwright/test';

test('dangquyun Homepage', async ({ page, browserName }) => {
  await page.goto('https://app.dangquyun.com/application/');

  //输入用户名
  await page.locator('#account').fill("1873910517@qq.com");

  //输入密码
  await page.locator('#password').fill("Aa123456#");

  //点击登录按钮
  await page.locator("#login-form > div:nth-child(6) > button").click();

  await expect(page).toHaveURL('https://app.dangquyun.com/tabs/home');

  await page.screenshot({ path: 'homepage-'+browserName+'.png', fullPage: true });
});