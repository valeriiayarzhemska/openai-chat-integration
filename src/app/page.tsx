export default function Home() {
  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100 py-12 px-4">
      <main className="max-w-5xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-5xl font-bold text-gray-900 mb-4">
            AWS Static Site Deployment
          </h1>
          <p className="text-xl text-gray-600">
            Next.js Application with Full CI/CD Pipeline on AWS
          </p>
          <p className="text-sm text-gray-500 mt-2">PDP - March 2026</p>
          <div className="mt-4 inline-block bg-blue-600 text-white px-6 py-2 rounded-full text-sm font-medium">
            🌐 Live on CloudFront: d1fvvbt7d0mojz.cloudfront.net
          </div>
        </div>

        {/* Project Overview */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            📋 Project Overview
          </h2>
          <p className="text-gray-700 mb-4">
            This project demonstrates a complete AWS cloud deployment architecture for a Next.js static site with automated CI/CD pipeline. 
            The application leverages modern cloud infrastructure to deliver a fast, scalable, and highly available web experience.
          </p>
          <div className="bg-blue-50 border-l-4 border-blue-500 p-4 rounded">
            <p className="text-sm text-gray-700">
              <strong>Key Achievement:</strong> Automated deployment pipeline that builds, tests, and deploys on every Git push with 
              automatic CloudFront cache invalidation for instant updates.
            </p>
          </div>
        </div>

        {/* Technology Stack */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-6">
            🛠️ Technology Stack
          </h2>
          
          <div className="grid md:grid-cols-2 gap-6">
            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-3">Frontend</h3>
              <ul className="space-y-2 text-gray-700">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Next.js 16.1.6</strong> - React framework with static export</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>React 19.2.3</strong> - UI library</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>TypeScript</strong> - Type-safe JavaScript</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Tailwind CSS</strong> - Utility-first styling</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Jest</strong> - Testing framework</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>ESLint</strong> - Code quality</span>
                </li>
              </ul>
            </div>

            <div>
              <h3 className="text-lg font-semibold text-gray-800 mb-3">AWS Services</h3>
              <ul className="space-y-2 text-gray-700">
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>S3</strong> - Static file hosting</span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>CloudFront</strong> - Global CDN with HTTPS</span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>CodePipeline</strong> - CI/CD orchestration</span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>CodeBuild</strong> - Build automation</span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>Systems Manager</strong> - Parameter Store for secrets</span>
                </li>
                <li className="flex items-start">
                  <span className="text-orange-500 mr-2">☁️</span>
                  <span><strong>IAM</strong> - Access management & roles</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* CI/CD Pipeline */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            🔄 CI/CD Pipeline Architecture
          </h2>
          <div className="space-y-4">
            <div className="flex items-start space-x-4">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-500 text-white rounded-full flex items-center justify-center font-bold">
                1
              </div>
              <div>
                <h4 className="font-semibold text-gray-800">Source Stage - GitHub</h4>
                <p className="text-sm text-gray-600">
                  CodePipeline automatically detects changes pushed to the main branch (valeriiayarzhemska/aws-test) 
                  via GitHub connection.
                </p>
              </div>
            </div>
            <div className="flex items-start space-x-4">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-500 text-white rounded-full flex items-center justify-center font-bold">
                2
              </div>
              <div>
                <h4 className="font-semibold text-gray-800">Build Stage - CodeBuild</h4>
                <p className="text-sm text-gray-600">
                  Runs npm install, builds Next.js static export, deploys to S3 using <code className="bg-gray-100 px-1">aws s3 sync</code>, 
                  and invalidates CloudFront cache for instant updates.
                </p>
              </div>
            </div>
            <div className="flex items-start space-x-4">
              <div className="flex-shrink-0 w-8 h-8 bg-blue-500 text-white rounded-full flex items-center justify-center font-bold">
                3
              </div>
              <div>
                <h4 className="font-semibold text-gray-800">Deploy Stage - S3 + CloudFront</h4>
                <p className="text-sm text-gray-600">
                  Static files served from S3 bucket through CloudFront CDN with global edge locations for optimal performance.
                </p>
              </div>
            </div>
          </div>
        </div>

        {/* What Was Done */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">
            ✅ Implementation Details
          </h2>
          <div className="grid md:grid-cols-2 gap-4">
            <div className="space-y-3">
              <h3 className="font-semibold text-gray-800 text-lg">Infrastructure Setup</h3>
              <ul className="space-y-2 text-sm text-gray-700">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Installed and configured AWS CLI</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Created IAM user with AdministratorAccess</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Set up S3 bucket for hosting (nextjs-app-hosting)</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Configured CloudFront with Origin Access Control</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Established GitHub connection via CodeStar</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>Created buildspec.yml for CodeBuild</span>
                </li>
              </ul>
            </div>
            <div className="space-y-3">
              <h3 className="font-semibold text-gray-800 text-lg">Security & Permissions</h3>
              <ul className="space-y-2 text-sm text-gray-700">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>IAM roles for CodeBuild and CodePipeline</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>S3 bucket policies for CloudFront access</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>CodeStar connection permissions</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>SSM Parameter Store for environment variables</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>CloudFront cache invalidation permissions</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2 mt-0.5">✓</span>
                  <span>CloudWatch logs for build monitoring</span>
                </li>
              </ul>
            </div>
          </div>
        </div>

        {/* Key Features */}
        <div className="bg-white rounded-2xl shadow-xl p-8 mb-8">
          <h2 className="text-2xl font-bold text-gray-800 mb-4">🚀 Key Features</h2>
          <div className="grid md:grid-cols-3 gap-4">
            <div className="bg-gradient-to-br from-blue-50 to-blue-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">⚡</div>
              <h3 className="font-semibold text-gray-800 mb-1">Lightning Fast</h3>
              <p className="text-sm text-gray-600">
                Static site with global CDN for sub-second load times
              </p>
            </div>
            <div className="bg-gradient-to-br from-green-50 to-green-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">🔒</div>
              <h3 className="font-semibold text-gray-800 mb-1">Secure</h3>
              <p className="text-sm text-gray-600">
                HTTPS, IAM roles, and restricted S3 access via OAC
              </p>
            </div>
            <div className="bg-gradient-to-br from-purple-50 to-purple-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">🤖</div>
              <h3 className="font-semibold text-gray-800 mb-1">Automated</h3>
              <p className="text-sm text-gray-600">
                Push to Git → Build → Test → Deploy automatically
              </p>
            </div>
            <div className="bg-gradient-to-br from-yellow-50 to-yellow-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">📊</div>
              <h3 className="font-semibold text-gray-800 mb-1">Scalable</h3>
              <p className="text-sm text-gray-600">
                AWS infrastructure handles any traffic volume
              </p>
            </div>
            <div className="bg-gradient-to-br from-red-50 to-red-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">💰</div>
              <h3 className="font-semibold text-gray-800 mb-1">Cost-Effective</h3>
              <p className="text-sm text-gray-600">
                Pay only for what you use, free tier eligible
              </p>
            </div>
            <div className="bg-gradient-to-br from-indigo-50 to-indigo-100 p-4 rounded-lg">
              <div className="text-2xl mb-2">🔄</div>
              <h3 className="font-semibold text-gray-800 mb-1">Cache Control</h3>
              <p className="text-sm text-gray-600">
                Automatic CloudFront invalidation on deployment
              </p>
            </div>
          </div>
        </div>

        {/* Technical Specs */}
        <div className="bg-gradient-to-r from-gray-800 to-gray-900 rounded-2xl shadow-xl p-8 text-white">
          <h2 className="text-2xl font-bold mb-4">⚙️ Technical Specifications</h2>
          <div className="grid md:grid-cols-2 gap-6 text-sm">
            <div>
              <p className="mb-2"><strong>AWS Account:</strong> 509194952232</p>
              <p className="mb-2"><strong>Region:</strong> us-east-1</p>
              <p className="mb-2"><strong>CloudFront ID:</strong> EIVN55CPBU4VU</p>
              <p className="mb-2"><strong>Pipeline:</strong> nextjs-app-pipeline</p>
            </div>
            <div>
              <p className="mb-2"><strong>Repository:</strong> valeriiayarzhemska/aws-test</p>
              <p className="mb-2"><strong>Node Version:</strong> 20.x</p>
              <p className="mb-2"><strong>Build Image:</strong> aws/codebuild/standard:7.0</p>
              <p className="mb-2"><strong>Deployment:</strong> Automated on Git push</p>
            </div>
          </div>
        </div>

        <div className="mt-8 text-center text-gray-600 text-sm">
          <p className="mb-2">Built with ❤️ using Next.js and AWS Cloud Infrastructure</p>
          <p className="text-xs text-gray-500">
            Complete CI/CD pipeline from development to production | March 2026
          </p>
        </div>
      </main>
    </div>
  );
}
